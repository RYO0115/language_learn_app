# クイズ機能のビジネスロジック層
# テスト開始・単語選択・回答記録・結果集計を担当する
import random
import re
from datetime import datetime, timezone

from sqlalchemy import Integer, func
from sqlalchemy.orm import Session

from language_learn.config import settings
from language_learn.core.exceptions import QuizSessionError
from language_learn.features.quiz.models import (
    QuizAnswer,
    QuizSession,
    QuizSessionWord,
    QuizSessionWordChoice,
    WordSimilarity,
)
from language_learn.features.quiz.schemas import QuizResultResponse, QuizWordResult
from language_learn.features.words.models import ExampleSentence, Word

# 穴埋め3択テストの1問あたりの選択肢数（正解1件 + 誤答2件）
FILL_BLANK_CHOICE_COUNT = 3

# 出題済み（テスト済み）単語のうち、正答率に関わらず「未出題期間ベース」で
# 優先的に再出題するスロットの割合。正答率が高い単語でも、長期間出題されていなければ
# このスロットで定期的に再出題される（スペースド・リピティション的な振る舞い）。
STALE_WORD_QUOTA_RATIO = 0.1


def select_quiz_words(
    db: Session, count: int, eligible_word_ids: set[int] | None = None
) -> list[int]:
    """クイズに出題する単語 ID リストを選択する。

    優先度:
    1. 一度もテストしていない単語（ランダム順）
    2. 残りスロットの一部（最大 STALE_WORD_QUOTA_RATIO 割合）は、
       正答率に関わらず最後に出題してから最も時間が経過している単語を優先する
    3. 正答率が低い単語（低い順、同率はランダム）
    4. それ以外の単語（ランダム順）

    合計 count 件（登録単語数が少ない場合は全件）を返す。
    eligible_word_ids を指定した場合、出題対象をその集合に絞る
    （穴埋め3択テストのように、出題可能な単語が限られるクイズタイプ用）。
    """
    all_word_ids: list[int] = [row[0] for row in db.query(Word.id).all()]
    if eligible_word_ids is not None:
        all_word_ids = [wid for wid in all_word_ids if wid in eligible_word_ids]
    if not all_word_ids:
        return []

    # 回答済み単語の集計: word_id -> (total, correct)
    answer_stats: dict[int, tuple[int, int]] = {}
    rows = (
        db.query(
            QuizAnswer.word_id,
            func.count(QuizAnswer.id).label("total"),
            func.sum(func.cast(QuizAnswer.is_correct, Integer)).label("correct"),
        )
        .group_by(QuizAnswer.word_id)
        .all()
    )
    for row in rows:
        answer_stats[row.word_id] = (row.total or 0, row.correct or 0)

    # 単語ごとの最終出題日時: word_id -> last_answered_at
    last_answered_at: dict[int, datetime] = {
        row.word_id: row.last_answered_at
        for row in (
            db.query(
                QuizAnswer.word_id,
                func.max(QuizAnswer.answered_at).label("last_answered_at"),
            )
            .group_by(QuizAnswer.word_id)
            .all()
        )
    }

    # 未テストの単語
    untested = [wid for wid in all_word_ids if wid not in answer_stats]
    random.shuffle(untested)

    # テスト済みの単語（未出題期間優先スロット用に分離する前の全体）
    tested = [wid for wid in all_word_ids if wid in answer_stats]

    selected: list[int] = []
    remaining = count

    take_untested = untested[:remaining]
    selected.extend(take_untested)
    remaining -= len(take_untested)

    if remaining > 0 and tested:
        # 未出題期間が長い順（古い順）に並べ、一定割合を正答率に関わらず優先採用する
        stale_quota = min(remaining, max(1, int(remaining * STALE_WORD_QUOTA_RATIO)))
        stale_sorted = sorted(tested, key=lambda wid: last_answered_at[wid])
        stale_candidates = stale_sorted[:stale_quota]
        selected.extend(stale_candidates)
        remaining -= len(stale_candidates)

        # 残りは正答率が低い順（同率はランダム）に採用する
        stale_candidate_set = set(stale_candidates)
        rest = [wid for wid in tested if wid not in stale_candidate_set]
        random.shuffle(rest)
        rest.sort(
            key=lambda wid: answer_stats[wid][1] / answer_stats[wid][0]
            if answer_stats[wid][0] > 0
            else 0.0
        )
        selected.extend(rest[:remaining])

    # 最終的にシャッフルして出題順をランダム化
    random.shuffle(selected)
    return selected


def get_fill_blank_eligible_word_ids(db: Session) -> list[int]:
    """穴埋め3択テストに出題可能な単語 ID リストを返す。

    条件: 品詞が設定済み・例文が1件以上ある・類似単語候補（word_similarities）が
    2件以上ある（誤答選択肢2件を確保できる）単語。
    """
    similarity_counts = (
        db.query(WordSimilarity.word_id, func.count(WordSimilarity.id).label("cnt"))
        .group_by(WordSimilarity.word_id)
        .having(func.count(WordSimilarity.id) >= FILL_BLANK_CHOICE_COUNT - 1)
        .all()
    )
    candidate_ids = {row.word_id for row in similarity_counts}
    if not candidate_ids:
        return []

    with_pos_ids = {
        row[0]
        for row in db.query(Word.id).filter(
            Word.id.in_(candidate_ids),
            Word.part_of_speech.isnot(None),
            Word.part_of_speech != "",
        ).all()
    }
    if not with_pos_ids:
        return []

    with_examples_ids = {
        row[0]
        for row in db.query(ExampleSentence.word_id)
        .filter(ExampleSentence.word_id.in_(with_pos_ids))
        .distinct()
        .all()
    }
    return [wid for wid in with_pos_ids if wid in with_examples_ids]


def is_fill_blank_unlocked(db: Session) -> bool:
    """穴埋め3択テストが出題可能な状態かどうかを返す。"""
    return len(get_fill_blank_eligible_word_ids(db)) > 0


def _build_fill_blank_question(db: Session, session_word: QuizSessionWord, word: Word) -> None:
    """穴埋め3択テスト1問分のデータ（出題例文・3択選択肢）を作成して session_word に紐づける。"""
    sentences = list(word.example_sentences)
    if not sentences:
        return
    sentence = random.choice(sentences)
    session_word.example_sentence_id = sentence.id

    similar_ids = [
        row[0]
        for row in db.query(WordSimilarity.similar_word_id)
        .filter(WordSimilarity.word_id == word.id)
        .order_by(WordSimilarity.rank)
        .all()
    ]
    random.shuffle(similar_ids)
    distractor_ids = similar_ids[: FILL_BLANK_CHOICE_COUNT - 1]

    choice_word_ids = [word.id, *distractor_ids]
    random.shuffle(choice_word_ids)

    for wid in choice_word_ids:
        db.add(QuizSessionWordChoice(
            session_word_id=session_word.id,
            word_id=wid,
            is_correct=(wid == word.id),
        ))


def start_quiz(db: Session, quiz_type: str = "meaning") -> QuizSession:
    """新しいクイズセッションを開始する。単語を選択してセッションに紐づける。

    quiz_type: "meaning"（意味確認テスト）または "fill_blank"（例文穴埋め3択テスト）
    """
    if quiz_type == "fill_blank":
        eligible_ids = set(get_fill_blank_eligible_word_ids(db))
        word_ids = select_quiz_words(db, settings.quiz_question_count, eligible_word_ids=eligible_ids)
        if not word_ids:
            raise QuizSessionError(
                "穴埋め3択テストに出題できる単語がありません。"
                "同じ品詞の単語を3件以上、例文付きで登録してください。"
            )
    else:
        word_ids = select_quiz_words(db, settings.quiz_question_count)
        if not word_ids:
            raise QuizSessionError("テスト可能な単語がありません。まず単語を登録してください。")

    now = datetime.now(timezone.utc)
    session = QuizSession(started_at=now)
    db.add(session)
    db.flush()

    words_by_id = {w.id: w for w in db.query(Word).filter(Word.id.in_(word_ids)).all()}

    for order, word_id in enumerate(word_ids, start=1):
        session_word = QuizSessionWord(
            session_id=session.id,
            word_id=word_id,
            order=order,
            is_answered=False,
            quiz_type=quiz_type,
        )
        db.add(session_word)
        db.flush()  # session_word.id を確定させる（選択肢の紐付けに必要）

        if quiz_type == "fill_blank":
            _build_fill_blank_question(db, session_word, words_by_id[word_id])

    db.commit()
    db.refresh(session)
    return session


def get_next_question(db: Session, session_id: int) -> tuple[QuizSessionWord | None, int, int]:
    """次の未回答問題を返す。

    Returns:
        (QuizSessionWord | None, current_order, total_count)
        未回答がなければ None を返す。
    """
    total = (
        db.query(func.count(QuizSessionWord.id))
        .filter(QuizSessionWord.session_id == session_id)
        .scalar()
        or 0
    )
    next_q = (
        db.query(QuizSessionWord)
        .filter(
            QuizSessionWord.session_id == session_id,
            QuizSessionWord.is_answered.is_(False),
        )
        .order_by(QuizSessionWord.order)
        .first()
    )
    answered = (
        db.query(func.count(QuizSessionWord.id))
        .filter(
            QuizSessionWord.session_id == session_id,
            QuizSessionWord.is_answered.is_(True),
        )
        .scalar()
        or 0
    )
    return next_q, answered + 1, total


def submit_answer(
    db: Session, session_id: int, word_id: int, is_correct: bool
) -> bool:
    """回答を記録し、全問終了した場合は True を返す。"""
    now = datetime.now(timezone.utc)

    # 回答を保存
    db.add(QuizAnswer(
        session_id=session_id,
        word_id=word_id,
        is_correct=is_correct,
        answered_at=now,
    ))

    # 出題単語を回答済みに更新
    session_word = (
        db.query(QuizSessionWord)
        .filter(
            QuizSessionWord.session_id == session_id,
            QuizSessionWord.word_id == word_id,
            QuizSessionWord.is_answered.is_(False),
        )
        .first()
    )
    if session_word:
        session_word.is_answered = True

    db.flush()

    # 全問回答済みかチェック
    remaining = (
        db.query(func.count(QuizSessionWord.id))
        .filter(
            QuizSessionWord.session_id == session_id,
            QuizSessionWord.is_answered.is_(False),
        )
        .scalar()
        or 0
    )
    is_completed = remaining == 0

    if is_completed:
        session = db.query(QuizSession).filter(QuizSession.id == session_id).first()
        if session:
            session.completed_at = now

        # 学習記録を更新（streak 機能との連携）
        from language_learn.features.streak.service import record_study
        record_study(db, now.date())

    db.commit()
    return is_completed


def _blank_word_in_sentence(sentence_en: str, word_text: str) -> str:
    """例文中の対象単語を "_____" に置き換える（単語境界・大文字小文字を無視して1箇所のみ）。

    活用形（過去形・複数形など）には対応しないため、原形のまま例文中に
    登場しない場合は置き換えられず、例文がそのまま返る。
    """
    pattern = re.compile(r"\b" + re.escape(word_text) + r"\b", re.IGNORECASE)
    blanked, count = pattern.subn("_____", sentence_en, count=1)
    return blanked if count else sentence_en


def get_fill_blank_question_data(db: Session, session_word: QuizSessionWord) -> dict:
    """穴埋め3択テストの出題画面用データ（穴埋め英文・3択選択肢）を返す。"""
    word = db.query(Word).filter(Word.id == session_word.word_id).first()
    sentence = (
        db.query(ExampleSentence)
        .filter(ExampleSentence.id == session_word.example_sentence_id)
        .first()
    )
    sentence_en_blanked = _blank_word_in_sentence(sentence.sentence_en, word.word) if sentence and word else ""

    choice_rows = (
        db.query(QuizSessionWordChoice)
        .filter(QuizSessionWordChoice.session_word_id == session_word.id)
        .order_by(QuizSessionWordChoice.id)
        .all()
    )
    choice_words = {
        w.id: w.word
        for w in db.query(Word).filter(Word.id.in_([c.word_id for c in choice_rows])).all()
    }
    choices = [{"word_id": c.word_id, "text": choice_words.get(c.word_id, "")} for c in choice_rows]

    return {
        "word": word,
        "sentence_en_blanked": sentence_en_blanked,
        "choices": choices,
    }


def submit_fill_blank_answer(
    db: Session, session_id: int, session_word_id: int, selected_word_id: int
) -> dict:
    """穴埋め3択テストの回答を記録し、フィードバック画面用データを返す。"""
    session_word = (
        db.query(QuizSessionWord)
        .filter(QuizSessionWord.id == session_word_id, QuizSessionWord.session_id == session_id)
        .first()
    )
    if not session_word:
        raise QuizSessionError("出題情報が見つかりません。")

    choice_rows = (
        db.query(QuizSessionWordChoice)
        .filter(QuizSessionWordChoice.session_word_id == session_word.id)
        .order_by(QuizSessionWordChoice.id)
        .all()
    )
    correct_choice = next((c for c in choice_rows if c.is_correct), None)
    is_correct = correct_choice is not None and selected_word_id == correct_choice.word_id

    now = datetime.now(timezone.utc)
    db.add(QuizAnswer(
        session_id=session_id,
        word_id=session_word.word_id,
        is_correct=is_correct,
        answered_at=now,
    ))
    session_word.is_answered = True
    db.flush()

    remaining = (
        db.query(func.count(QuizSessionWord.id))
        .filter(
            QuizSessionWord.session_id == session_id,
            QuizSessionWord.is_answered.is_(False),
        )
        .scalar()
        or 0
    )
    is_completed = remaining == 0

    if is_completed:
        session = db.query(QuizSession).filter(QuizSession.id == session_id).first()
        if session:
            session.completed_at = now

        from language_learn.features.streak.service import record_study
        record_study(db, now.date())

    # フィードバック用データ: 例文訳・各選択肢の単語の意味・正誤
    sentence = (
        db.query(ExampleSentence)
        .filter(ExampleSentence.id == session_word.example_sentence_id)
        .first()
    )
    choice_word_objs = {
        w.id: w
        for w in db.query(Word).filter(Word.id.in_([c.word_id for c in choice_rows])).all()
    }
    choice_details = [
        {
            "word_id": c.word_id,
            "word": choice_word_objs[c.word_id].word if c.word_id in choice_word_objs else "",
            "meaning": choice_word_objs[c.word_id].meaning if c.word_id in choice_word_objs else "",
            "is_correct": c.is_correct,
            "is_selected": c.word_id == selected_word_id,
        }
        for c in choice_rows
    ]

    db.commit()

    return {
        "is_completed": is_completed,
        "is_correct": is_correct,
        "sentence_en": sentence.sentence_en if sentence else "",
        "sentence_ja": sentence.sentence_ja if sentence else "",
        "choices": choice_details,
    }


def get_quiz_result(db: Session, session_id: int) -> QuizResultResponse:
    """クイズセッションの最終結果を集計して返す。"""
    answers = (
        db.query(QuizAnswer)
        .filter(QuizAnswer.session_id == session_id)
        .all()
    )
    total = len(answers)
    correct = sum(1 for a in answers if a.is_correct)
    incorrect = total - correct
    accuracy = round(correct / total * 100, 1) if total > 0 else 0.0

    # 不正解の単語を取得
    wrong_words = []
    for answer in answers:
        if not answer.is_correct:
            word = db.query(Word).filter(Word.id == answer.word_id).first()
            if word:
                wrong_words.append(QuizWordResult(
                    word_id=word.id,
                    word=word.word,
                    meaning=word.meaning,
                    is_correct=False,
                ))

    session = db.query(QuizSession).filter(QuizSession.id == session_id).first()
    completed_at = session.completed_at if session else datetime.now(timezone.utc)

    return QuizResultResponse(
        session_id=session_id,
        total=total,
        correct=correct,
        incorrect=incorrect,
        accuracy=accuracy,
        wrong_words=wrong_words,
        completed_at=completed_at or datetime.now(timezone.utc),
    )
