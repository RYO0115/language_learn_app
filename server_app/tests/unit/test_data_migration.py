# 既存データのクリーンアップ（normalize_existing_words）と、バージョン連動の
# データマイグレーション実行制御（run_data_migrations）を in-memory DB で検証する。
from datetime import datetime, timedelta, timezone

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

from language_learn.core.base_model import Base
from language_learn.core.migrations import (
    get_data_version,
    run_data_migrations,
    set_data_version,
)
from language_learn.features.quiz.models import QuizAnswer  # noqa: F401
from language_learn.features.words.models import Word
from language_learn.features.words.schemas import WordCreate
from language_learn.features.words.service import create_word, normalize_existing_words

ZERO_WIDTH_SPACE = "\u200b"

_BASE_TIME = datetime(2026, 1, 1, tzinfo=timezone.utc)


def _insert_raw_word(db: Session, text: str, created_offset_sec: int, pos: str | None = None) -> Word:
    """正規化を通さず Word 行を直接作成する（過去のゴミデータを再現するため）。"""
    word = Word(
        word=text,
        meaning=f"meaning of {text}",
        part_of_speech=pos,
        created_at=_BASE_TIME + timedelta(seconds=created_offset_sec),
        updated_at=_BASE_TIME + timedelta(seconds=created_offset_sec),
    )
    db.add(word)
    db.flush()
    return word


# ---- normalize_existing_words（セッション単位で検証） ----


def test_normalize_existing_words_trims_in_place(db: Session):
    # ゼロ幅文字付きで保存されてしまった単語を正規化（衝突なし）
    word = _insert_raw_word(db, f"apple{ZERO_WIDTH_SPACE}", 0)
    db.commit()

    changed = normalize_existing_words(db)

    assert changed == 1
    db.refresh(word)
    assert word.word == "apple"


def test_normalize_existing_words_no_change_when_already_clean(db: Session):
    create_word(db, WordCreate(word="apple", meaning="りんご"))
    changed = normalize_existing_words(db)
    assert changed == 0


def test_normalize_existing_words_merges_duplicate_and_keeps_history(db: Session):
    # canonical（先に登録）と、ゼロ幅文字付きの重複（後から登録）
    canonical = _insert_raw_word(db, "apple", 0)
    dup = _insert_raw_word(db, f"apple{ZERO_WIDTH_SPACE}", 10)
    # 重複側にクイズ回答履歴を付けておく（マージで canonical に付け替わること）
    db.add(QuizAnswer(session_id=1, word_id=dup.id, is_correct=True, answered_at=_BASE_TIME))
    db.commit()
    dup_id = dup.id
    canonical_id = canonical.id

    changed = normalize_existing_words(db)

    assert changed == 1
    # 重複行は削除され、canonical だけが残る
    remaining = db.query(Word).all()
    assert [w.id for w in remaining] == [canonical_id]
    assert remaining[0].word == "apple"
    # クイズ履歴は canonical に付け替えられている
    answers = db.query(QuizAnswer).all()
    assert len(answers) == 1
    assert answers[0].word_id == canonical_id
    assert db.query(Word).filter(Word.id == dup_id).first() is None


# ---- run_data_migrations（エンジン単位・バージョン連動を検証） ----


@pytest.fixture
def engine():
    """全接続で同一の in-memory DB を共有するエンジン（StaticPool）。"""
    eng = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(bind=eng)
    yield eng
    eng.dispose()


def test_run_data_migrations_runs_once_per_version(engine):
    session = sessionmaker(bind=engine)()
    try:
        _insert_raw_word(session, f"apple{ZERO_WIDTH_SPACE}", 0)
        session.commit()
    finally:
        session.close()

    # 初回（未記録）は実行され、バージョンが記録される
    assert run_data_migrations(engine, "0.4.3") is True
    assert get_data_version(engine) == "0.4.3"

    check = sessionmaker(bind=engine)()
    try:
        assert check.query(Word).filter(Word.word == "apple").count() == 1
    finally:
        check.close()

    # 同じバージョンでは再実行されない
    assert run_data_migrations(engine, "0.4.3") is False


def test_run_data_migrations_reruns_on_version_change(engine):
    set_data_version(engine, "0.4.3")
    # 別バージョンになったら再実行される
    assert run_data_migrations(engine, "0.5.0") is True
    assert get_data_version(engine) == "0.5.0"
