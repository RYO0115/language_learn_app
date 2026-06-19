# クイズ機能のビジネスロジック層
# テスト開始・単語選択・回答記録・結果集計を担当する
import random
from datetime import datetime, timezone

from sqlalchemy import Integer, func
from sqlalchemy.orm import Session

from language_learn.config import settings
from language_learn.core.exceptions import QuizSessionError
from language_learn.features.quiz.models import QuizAnswer, QuizSession, QuizSessionWord
from language_learn.features.quiz.schemas import QuizResultResponse, QuizWordResult
from language_learn.features.words.models import Word

# 出題済み（テスト済み）単語のうち、正答率に関わらず「未出題期間ベース」で
# 優先的に再出題するスロットの割合。正答率が高い単語でも、長期間出題されていなければ
# このスロットで定期的に再出題される（スペースド・リピティション的な振る舞い）。
STALE_WORD_QUOTA_RATIO = 0.1


def select_quiz_words(db: Session, count: int) -> list[int]:
    """クイズに出題する単語 ID リストを選択する。

    優先度:
    1. 一度もテストしていない単語（ランダム順）
    2. 残りスロットの一部（最大 STALE_WORD_QUOTA_RATIO 割合）は、
       正答率に関わらず最後に出題してから最も時間が経過している単語を優先する
    3. 正答率が低い単語（低い順、同率はランダム）
    4. それ以外の単語（ランダム順）

    合計 count 件（登録単語数が少ない場合は全件）を返す。
    """
    all_word_ids: list[int] = [row[0] for row in db.query(Word.id).all()]
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


def start_quiz(db: Session) -> QuizSession:
    """新しいクイズセッションを開始する。単語を選択してセッションに紐づける。"""
    word_ids = select_quiz_words(db, settings.quiz_question_count)
    if not word_ids:
        raise QuizSessionError("テスト可能な単語がありません。まず単語を登録してください。")

    now = datetime.now(timezone.utc)
    session = QuizSession(started_at=now)
    db.add(session)
    db.flush()

    for order, word_id in enumerate(word_ids, start=1):
        db.add(QuizSessionWord(
            session_id=session.id,
            word_id=word_id,
            order=order,
            is_answered=False,
        ))

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
