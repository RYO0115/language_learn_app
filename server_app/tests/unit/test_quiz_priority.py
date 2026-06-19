# select_quiz_words() の出題優先度ロジックに対するユニットテスト
# ブラウザ越しでは検証しづらい選択アルゴリズムを、独立した in-memory DB で直接検証する
from datetime import datetime, timedelta, timezone

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

from language_learn.core.base_model import Base
from language_learn.features.quiz.models import QuizAnswer
from language_learn.features.quiz.service import select_quiz_words
from language_learn.features.words.models import Word


@pytest.fixture
def db():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(bind=engine)
    SessionLocal = sessionmaker(bind=engine)
    session = SessionLocal()
    try:
        yield session
    finally:
        session.close()


def _add_word(db: Session, word: str) -> Word:
    w = Word(word=word, meaning=f"meaning of {word}")
    db.add(w)
    db.flush()
    return w


def _add_answer(db: Session, word_id: int, is_correct: bool, answered_at: datetime) -> None:
    db.add(QuizAnswer(
        session_id=1,
        word_id=word_id,
        is_correct=is_correct,
        answered_at=answered_at,
    ))
    db.flush()


def test_untested_words_are_prioritized(db: Session):
    tested = _add_word(db, "tested")
    untested = _add_word(db, "untested")
    _add_answer(db, tested.id, True, datetime.now(timezone.utc))
    db.commit()

    selected = select_quiz_words(db, count=1)
    assert selected == [untested.id]


def test_stale_high_accuracy_word_resurfaces_over_recently_tested_low_accuracy_word(db: Session):
    """正答率が高くても長期間出題されていない単語は、優先スロットで再出題される。"""
    now = datetime.now(timezone.utc)
    long_ago = now - timedelta(days=365)

    # 正答率100%だが1年間出題されていない単語
    stale_high_accuracy = _add_word(db, "stale_high_accuracy")
    _add_answer(db, stale_high_accuracy.id, True, long_ago)

    # 正答率0%で直近に出題された単語を多数用意し、通常ロジックなら優先されるようにする
    recent_low_accuracy_ids = []
    for i in range(5):
        w = _add_word(db, f"recent_low_accuracy_{i}")
        _add_answer(db, w.id, False, now)
        recent_low_accuracy_ids.append(w.id)

    db.commit()

    # count=1（remaining=1 のため stale_quota は max(1, int(1*0.1))=1 で必ず確保される）
    selected = select_quiz_words(db, count=1)
    assert selected == [stale_high_accuracy.id]


def test_returns_all_words_when_fewer_than_count(db: Session):
    ids = [_add_word(db, f"word_{i}").id for i in range(3)]
    db.commit()

    selected = select_quiz_words(db, count=20)
    assert sorted(selected) == sorted(ids)


def test_empty_db_returns_empty_list(db: Session):
    assert select_quiz_words(db, count=20) == []
