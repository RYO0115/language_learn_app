# 単語帳機能のビジネスロジック層
# 単語の CRUD 操作・正答率計算などを提供する
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


def create_word(db: Session, data: WordCreate) -> Word:
    """単語を新規登録する。大文字小文字を区別せず重複チェックを行う。"""
    # 重複チェック（case-insensitive）
    existing = (
        db.query(Word).filter(func.lower(Word.word) == data.word.lower().strip()).first()
    )
    if existing:
        raise DuplicateWordError(f"単語「{data.word}」はすでに登録されています。")

    now = datetime.now(timezone.utc)

    # 単語本体を作成
    word = Word(
        word=data.word.strip(),
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
    return word


def get_word(db: Session, word_id: int) -> Word:
    """ID で単語を取得する。見つからない場合は WordNotFoundError を送出する。"""
    word = db.query(Word).filter(Word.id == word_id).first()
    if not word:
        raise WordNotFoundError(f"単語 ID {word_id} が見つかりません。")
    return word


def get_word_by_text(db: Session, word_text: str) -> Word | None:
    """英単語テキストで単語を取得する（大文字小文字を区別しない）。"""
    return (
        db.query(Word)
        .filter(func.lower(Word.word) == word_text.lower().strip())
        .first()
    )


def list_words(
    db: Session,
    sort_by: SortBy = "created_at_desc",
    search: str = "",
) -> list[WordListItem]:
    """単語一覧を取得する。ソート・検索フィルタに対応。"""
    # 遅延インポートで循環参照を回避
    from sqlalchemy import Integer as SAInteger, case
    from language_learn.features.quiz.models import QuizAnswer

    # 正答率サブクエリ
    accuracy_subq = (
        db.query(
            QuizAnswer.word_id.label("word_id"),
            func.count(QuizAnswer.id).label("total"),
            func.sum(case((QuizAnswer.is_correct == True, 1), else_=0)).label("correct"),
        )
        .group_by(QuizAnswer.word_id)
        .subquery()
    )

    query = db.query(Word).outerjoin(accuracy_subq, Word.id == accuracy_subq.c.word_id)

    # 検索フィルタ（単語・意味に対して部分一致）
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
            .filter(QuizAnswer.word_id == w.id, QuizAnswer.is_correct == True)
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

    # 出典情報を追加（既存は保持）
    if data.source is not None:
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
    return word


def delete_word(db: Session, word_id: int) -> None:
    """単語を削除する。関連する例文・出典情報・クイズ回答は CASCADE で自動削除される。"""
    word = get_word(db, word_id)
    db.delete(word)
    db.commit()


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
    words = db.query(Word).filter(Word.id.in_(word_ids)).all()
    count = len(words)
    for word in words:
        db.delete(word)
    db.commit()
    return count


def get_word_count(db: Session) -> int:
    """登録単語の総数を返す。"""
    return db.query(func.count(Word.id)).scalar() or 0
