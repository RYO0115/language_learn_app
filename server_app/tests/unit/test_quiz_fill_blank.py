# 穴埋め3択テストのアンロック判定・出題対象抽出・選択肢生成ロジックを検証するユニットテスト
from sqlalchemy.orm import Session

from language_learn.features.quiz.models import QuizSessionWordChoice
from language_learn.features.quiz.service import (
    get_fill_blank_eligible_word_ids,
    is_fill_blank_unlocked,
    start_quiz,
)
from language_learn.features.words.schemas import ExampleSentenceCreate, WordCreate, WordUpdate
from language_learn.features.words.service import create_word, update_word


def _create_with_example(db: Session, word: str, part_of_speech: str = "名詞") -> int:
    w = create_word(db, WordCreate(
        word=word,
        meaning=f"meaning of {word}",
        part_of_speech=part_of_speech,
        example_sentences=[
            ExampleSentenceCreate(sentence_en=f"I saw a {word} yesterday.", sentence_ja="example", order=1)
        ],
    ))
    return w.id


def test_not_unlocked_with_no_words(db: Session):
    assert is_fill_blank_unlocked(db) is False
    assert get_fill_blank_eligible_word_ids(db) == []


def test_not_unlocked_with_only_two_same_part_of_speech_words(db: Session):
    """同じ品詞の単語が2件では、誤答候補が1件しか確保できずアンロックされない。"""
    _create_with_example(db, "apple")
    _create_with_example(db, "apricot")
    assert is_fill_blank_unlocked(db) is False


def test_unlocked_with_three_same_part_of_speech_words(db: Session):
    ids = [_create_with_example(db, w) for w in ("apple", "apricot", "avocado")]
    assert is_fill_blank_unlocked(db) is True
    assert sorted(get_fill_blank_eligible_word_ids(db)) == sorted(ids)


def test_word_without_example_sentence_is_not_eligible(db: Session):
    a = _create_with_example(db, "apple")
    b = _create_with_example(db, "apricot")
    from language_learn.features.words.models import Word
    c = Word(word="avocado", meaning="m", part_of_speech="名詞")
    db.add(c)
    db.commit()
    # avocado には例文がないため、似ている単語の登録対象にはなるが出題対象からは除外される
    from language_learn.features.quiz.similarity_service import recompute_similarities_for_part_of_speech
    recompute_similarities_for_part_of_speech(db, "名詞")
    db.commit()

    eligible = get_fill_blank_eligible_word_ids(db)
    assert c.id not in eligible
    assert a in eligible
    assert b in eligible


def test_unlocked_becomes_false_after_part_of_speech_changes_away(db: Session):
    a = _create_with_example(db, "apple")
    _create_with_example(db, "apricot")
    _create_with_example(db, "avocado")
    assert is_fill_blank_unlocked(db) is True

    # 1件を別の品詞に変更すると名詞グループが2件になり、アンロック条件を満たさなくなる
    update_word(db, a, WordUpdate(meaning="updated", part_of_speech="動詞"))
    assert is_fill_blank_unlocked(db) is False


def test_start_quiz_fill_blank_creates_three_choices_with_one_correct(db: Session):
    ids = [_create_with_example(db, w) for w in ("apple", "apricot", "avocado")]

    session = start_quiz(db, quiz_type="fill_blank")

    from language_learn.features.quiz.models import QuizSessionWord
    session_words = (
        db.query(QuizSessionWord).filter(QuizSessionWord.session_id == session.id).all()
    )
    assert len(session_words) == len(ids)

    for sw in session_words:
        assert sw.quiz_type == "fill_blank"
        assert sw.example_sentence_id is not None

        choices = (
            db.query(QuizSessionWordChoice)
            .filter(QuizSessionWordChoice.session_word_id == sw.id)
            .all()
        )
        assert len(choices) == 3
        assert len({c.word_id for c in choices}) == 3  # 重複なし
        correct_choices = [c for c in choices if c.is_correct]
        assert len(correct_choices) == 1
        assert correct_choices[0].word_id == sw.word_id


def test_start_quiz_fill_blank_raises_when_not_unlocked(db: Session):
    import pytest

    from language_learn.core.exceptions import QuizSessionError

    with pytest.raises(QuizSessionError):
        start_quiz(db, quiz_type="fill_blank")
