# 単語帳機能のビジネスロジック層
# 単語の CRUD 操作・正答率計算などを提供する
import re
from datetime import datetime, timezone

from sqlalchemy import func
from sqlalchemy.orm import Session

from language_learn.core.exceptions import DuplicateWordError, WordNotFoundError
from language_learn.features.words.models import ExampleSentence, Word, WordSource
from language_learn.features.words.schemas import (
    SortBy,
    WordCreate,
    WordListItem,
    WordResponse,
    WordUpdate,
)

# iPhone のキーボード（予測変換・音声入力など）が単語の末尾に挿入することがある
# ゼロ幅・不可視文字。str.strip() では除去されないため、これらが付くと「見た目が同じ単語」が
# 別単語として扱われ、重複登録の見逃しや検索ミスの原因になる。正規化時に明示的に取り除く。
# （ユーザーの語彙内容ではなく Unicode の制御・書式文字＝技術的に閉じた集合なので固定リストでよい）
_INVISIBLE_CHARS = (
    "\u200b"  # ZERO WIDTH SPACE
    "\u200c"  # ZERO WIDTH NON-JOINER
    "\u200d"  # ZERO WIDTH JOINER
    "\u2060"  # WORD JOINER
    "\ufeff"  # ZERO WIDTH NO-BREAK SPACE (BOM)
    "\u00ad"  # SOFT HYPHEN
)
_INVISIBLE_TRANSLATION = dict.fromkeys(map(ord, _INVISIBLE_CHARS), None)


def normalize_word_text(text: str) -> str:
    """単語テキストを正規化する。

    末尾のゼロ幅・不可視文字や通常の空白（半角・全角・改行・NBSP など）を取り除き、
    内部の連続空白は 1 つに畳み込む。これにより「見た目が同じ単語」が空白の有無で
    別単語として扱われ、重複登録の見逃しや検索ミスが起きるのを防ぐ。
    """
    if not text:
        return ""
    text = text.translate(_INVISIBLE_TRANSLATION)
    return re.sub(r"\s+", " ", text).strip()


def _attach_accuracy(db: Session, word_id: int) -> tuple[float | None, int]:
    """指定単語の正答率とクイズ回答回数を計算して返す。

    quiz_answers テーブルを参照するため、遅延インポートで循環参照を回避する。
    """
    # 遅延インポート: quiz モデルは words に依存しないが、words から quiz を参照するため
    from sqlalchemy import Integer as SAInteger

    from language_learn.features.quiz.models import QuizAnswer

    rows = (
        db.query(
            func.count(QuizAnswer.id).label("total"),
            func.sum(func.cast(QuizAnswer.is_correct, SAInteger)).label("correct"),
        )
        .filter(QuizAnswer.word_id == word_id)
        .one()
    )
    total = rows.total or 0
    correct = rows.correct or 0
    if total == 0:
        return None, 0
    return round(correct / total * 100, 1), total


def _to_response(db: Session, word: Word) -> WordResponse:
    """Word モデルを WordResponse スキーマに変換する（正答率付き）。"""
    accuracy, quiz_count = _attach_accuracy(db, word.id)
    resp = WordResponse.model_validate(word)
    resp.accuracy = accuracy
    resp.quiz_count = quiz_count
    return resp


def _refresh_similarities_for_part_of_speech(db: Session, part_of_speech: str | None) -> None:
    """指定した品詞グループの類似単語（穴埋め3択テストの選択肢候補）を再計算してコミットする。

    遅延インポートで循環参照を回避する。
    """
    if not part_of_speech:
        return
    from language_learn.features.quiz.similarity_service import (
        recompute_similarities_for_part_of_speech,
    )
    recompute_similarities_for_part_of_speech(db, part_of_speech)
    db.commit()


def create_word(db: Session, data: WordCreate) -> Word:
    """単語を新規登録する。大文字小文字を区別せず重複チェックを行う。"""
    # 単語テキストを正規化（末尾のゼロ幅文字・空白の有無で別単語扱いになるのを防ぐ）
    word_text = normalize_word_text(data.word)
    # 重複チェック（case-insensitive）
    existing = (
        db.query(Word).filter(func.lower(Word.word) == word_text.lower()).first()
    )
    if existing:
        raise DuplicateWordError(f"単語「{word_text}」はすでに登録されています。")

    now = datetime.now(timezone.utc)

    # 単語本体を作成
    word = Word(
        word=word_text,
        reading=data.reading,
        meaning=data.meaning,
        part_of_speech=data.part_of_speech,
    )
    db.add(word)
    db.flush()  # word.id を確定させる

    # 例文を登録（label があれば品詞グループとして保存）
    for sent_data in data.example_sentences:
        sentence = ExampleSentence(
            word_id=word.id,
            sentence_en=sent_data.sentence_en,
            sentence_ja=sent_data.sentence_ja,
            order=sent_data.order,
            label=sent_data.label,
        )
        db.add(sentence)

    # 出典情報を登録（任意）
    if data.source:
        source = WordSource(
            word_id=word.id,
            source_type=data.source.source_type,
            title=data.source.title,
            url=data.source.url,
            page_number=data.source.page_number,
            detail=data.source.detail,
            created_at=now,
        )
        db.add(source)

    db.commit()
    db.refresh(word)

    # 穴埋め3択テスト用の類似単語候補を更新（同じ品詞グループ内で再計算）
    _refresh_similarities_for_part_of_speech(db, word.part_of_speech)

    return word


def get_word(db: Session, word_id: int) -> Word:
    """ID で単語を取得する。見つからない場合は WordNotFoundError を送出する。"""
    word = db.query(Word).filter(Word.id == word_id).first()
    if not word:
        raise WordNotFoundError(f"単語 ID {word_id} が見つかりません。")
    return word


def get_word_by_text(db: Session, word_text: str) -> Word | None:
    """英単語テキストで単語を取得する（大文字小文字を区別せず、空白・ゼロ幅文字を正規化）。"""
    normalized = normalize_word_text(word_text)
    if not normalized:
        return None
    return (
        db.query(Word)
        .filter(func.lower(Word.word) == normalized.lower())
        .first()
    )


def list_words(
    db: Session,
    sort_by: SortBy = "created_at_desc",
    search: str = "",
) -> list[WordListItem]:
    """単語一覧を取得する。ソート・検索フィルタに対応。"""
    # 遅延インポートで循環参照を回避
    from sqlalchemy import Integer as SAInteger
    from sqlalchemy import case

    from language_learn.features.quiz.models import QuizAnswer

    # 正答率サブクエリ
    accuracy_subq = (
        db.query(
            QuizAnswer.word_id.label("word_id"),
            func.count(QuizAnswer.id).label("total"),
            func.sum(case((QuizAnswer.is_correct.is_(True), 1), else_=0)).label("correct"),
        )
        .group_by(QuizAnswer.word_id)
        .subquery()
    )

    query = db.query(Word).outerjoin(accuracy_subq, Word.id == accuracy_subq.c.word_id)

    # 検索フィルタ（単語・意味に対して部分一致）
    # 検索語も正規化し、iPhone 等が末尾に付与する空白・ゼロ幅文字で 0 件になるのを防ぐ
    search = normalize_word_text(search)
    if search:
        query = query.filter(
            Word.word.ilike(f"%{search}%") | Word.meaning.ilike(f"%{search}%")
        )

    # ソート
    if sort_by == "created_at_desc":
        query = query.order_by(Word.created_at.desc())
    elif sort_by == "created_at_asc":
        query = query.order_by(Word.created_at.asc())
    elif sort_by == "word_asc":
        query = query.order_by(func.lower(Word.word).asc())
    elif sort_by == "word_desc":
        query = query.order_by(func.lower(Word.word).desc())
    elif sort_by == "accuracy_asc":
        # 未テストを先頭に、次に正答率が低い順
        query = query.order_by(
            accuracy_subq.c.total.is_(None).desc(),
            (func.cast(accuracy_subq.c.correct, SAInteger) * 1.0 / accuracy_subq.c.total).asc(),
        )

    words = query.all()

    # 正答率を付加して返す
    items = []
    for w in words:
        total_q = db.query(func.count(QuizAnswer.id)).filter(QuizAnswer.word_id == w.id).scalar() or 0
        correct_q = (
            db.query(func.count(QuizAnswer.id))
            .filter(QuizAnswer.word_id == w.id, QuizAnswer.is_correct.is_(True))
            .scalar()
            or 0
        )
        accuracy = round(correct_q / total_q * 100, 1) if total_q > 0 else None

        item = WordListItem.model_validate(w)
        item.accuracy = accuracy
        item.quiz_count = total_q
        items.append(item)

    return items


def update_word(db: Session, word_id: int, data: WordUpdate) -> Word:
    """単語情報を更新する。例文は全て置き換え（delete + insert）を行う。"""
    word = get_word(db, word_id)
    old_part_of_speech = word.part_of_speech

    if data.reading is not None:
        word.reading = data.reading
    if data.meaning is not None:
        word.meaning = data.meaning
    if data.part_of_speech is not None:
        word.part_of_speech = data.part_of_speech

    # 例文を置き換え
    if data.example_sentences is not None:
        for sent in word.example_sentences:
            db.delete(sent)
        db.flush()
        for sent_data in data.example_sentences:
            db.add(ExampleSentence(
                word_id=word.id,
                sentence_en=sent_data.sentence_en,
                sentence_ja=sent_data.sentence_ja,
                order=sent_data.order,
            ))

    # 出典情報を置き換え（既存を全削除してから新規追加）
    if data.source is not None:
        for src in word.sources:
            db.delete(src)
        db.flush()
        db.add(WordSource(
            word_id=word.id,
            source_type=data.source.source_type,
            title=data.source.title,
            url=data.source.url,
            page_number=data.source.page_number,
            detail=data.source.detail,
            created_at=datetime.now(timezone.utc),
        ))

    word.updated_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(word)

    # 穴埋め3択テスト用の類似単語候補を更新（品詞が変わった場合は旧・新両方のグループを再計算）
    _refresh_similarities_for_part_of_speech(db, old_part_of_speech)
    if word.part_of_speech != old_part_of_speech:
        _refresh_similarities_for_part_of_speech(db, word.part_of_speech)

    return word


def delete_word(db: Session, word_id: int) -> None:
    """単語を削除する。関連する例文・出典情報・クイズ回答は CASCADE で自動削除される。"""
    from language_learn.features.quiz.models import WordSimilarity

    word = get_word(db, word_id)
    part_of_speech = word.part_of_speech

    # FK の ON DELETE CASCADE は SQLite で強制有効化していないため、
    # 類似単語候補は明示的に削除してから単語本体を削除する
    db.query(WordSimilarity).filter(
        (WordSimilarity.word_id == word_id) | (WordSimilarity.similar_word_id == word_id)
    ).delete(synchronize_session=False)

    db.delete(word)
    db.commit()

    # 残った同品詞グループの類似単語候補を再計算
    _refresh_similarities_for_part_of_speech(db, part_of_speech)


def get_source_suggestions(db: Session) -> dict[str, list[str]]:
    """出典情報の入力補完用に、過去に登録されたユニークな値を返す。

    Returns:
        {"titles": [...], "urls": [...]} の形式で候補リストを返す。
    """
    from sqlalchemy import distinct

    titles = [
        row[0] for row in
        db.query(distinct(WordSource.title))
        .filter(WordSource.title.isnot(None), WordSource.title != "")
        .order_by(WordSource.title)
        .all()
    ]
    urls = [
        row[0] for row in
        db.query(distinct(WordSource.url))
        .filter(WordSource.url.isnot(None), WordSource.url != "")
        .order_by(WordSource.url)
        .all()
    ]
    return {"titles": titles, "urls": urls}


def bulk_delete_words(db: Session, word_ids: list[int]) -> int:
    """複数の単語をまとめて削除する。ORM 経由で削除し CASCADE が確実に動作するようにする。

    Returns:
        実際に削除した件数
    """
    from language_learn.features.quiz.models import WordSimilarity

    words = db.query(Word).filter(Word.id.in_(word_ids)).all()
    count = len(words)
    affected_parts_of_speech = {w.part_of_speech for w in words if w.part_of_speech}
    deleted_ids = [w.id for w in words]

    if deleted_ids:
        db.query(WordSimilarity).filter(
            WordSimilarity.word_id.in_(deleted_ids) | WordSimilarity.similar_word_id.in_(deleted_ids)
        ).delete(synchronize_session=False)

    for word in words:
        db.delete(word)
    db.commit()

    for pos in affected_parts_of_speech:
        _refresh_similarities_for_part_of_speech(db, pos)

    return count


def get_word_count(db: Session) -> int:
    """登録単語の総数を返す。"""
    return db.query(func.count(Word.id)).scalar() or 0


def normalize_existing_words(db: Session) -> int:
    """既存の全単語テキストを正規化し、正規化によって重複が生じた場合はマージする。

    過去のバグでゼロ幅文字・余分な空白が付いたまま登録された単語を、現在の正規化ルール
    （`normalize_word_text`）に揃えるためのデータマイグレーション。

    - 正規化しても他の単語と衝突しない場合: その場でテキストを書き換える。
    - 正規化の結果、既存の単語（大文字小文字を無視して同一）と重複する場合:
      先に登録された方を正準（canonical）として残し、重複側のクイズ回答・出題履歴を
      正準側へ付け替えてから重複行を削除する（学習記録を失わないため）。

    Returns:
        テキストを書き換えた、またはマージで削除した単語の件数。
    """
    from language_learn.features.quiz.models import (
        QuizAnswer,
        QuizSessionWord,
        QuizSessionWordChoice,
        WordSimilarity,
    )

    # 先に登録された単語を canonical にするため登録順で処理する
    words = db.query(Word).order_by(Word.created_at.asc(), Word.id.asc()).all()
    canonical_by_key: dict[str, Word] = {}
    affected_parts_of_speech: set[str] = set()
    changed = 0

    for word in words:
        normalized = normalize_word_text(word.word)
        # 正規化すると空になる異常データ（不可視文字のみ等）は触らずに残す
        if not normalized:
            continue
        key = normalized.lower()
        canonical = canonical_by_key.get(key)

        if canonical is None:
            canonical_by_key[key] = word
            if word.word != normalized:
                word.word = normalized
                changed += 1
                if word.part_of_speech:
                    affected_parts_of_speech.add(word.part_of_speech)
            continue

        # 正規化後に canonical と重複 → canonical へマージして重複行を削除
        for model in (QuizAnswer, QuizSessionWord, QuizSessionWordChoice):
            db.query(model).filter(model.word_id == word.id).update(
                {model.word_id: canonical.id}, synchronize_session=False
            )
        db.query(WordSimilarity).filter(
            (WordSimilarity.word_id == word.id) | (WordSimilarity.similar_word_id == word.id)
        ).delete(synchronize_session=False)
        for pos in (word.part_of_speech, canonical.part_of_speech):
            if pos:
                affected_parts_of_speech.add(pos)
        db.delete(word)  # 例文・出典は ORM カスケードで削除される
        changed += 1

    if changed:
        db.commit()
        # マージ・テキスト変更で影響を受けた品詞グループの類似単語候補を再計算
        for pos in affected_parts_of_speech:
            _refresh_similarities_for_part_of_speech(db, pos)

    return changed
