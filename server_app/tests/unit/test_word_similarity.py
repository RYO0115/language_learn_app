# 類似単語の事前計算ロジック（recompute_similarities_for_part_of_speech）と
# words/service.py の CRUD フックとの連携を in-memory DB で直接検証する
from sqlalchemy.orm import Session

from language_learn.features.quiz.models import WordSimilarity
from language_learn.features.quiz.similarity_service import (
    SIMILARITY_TOP_N,
    recompute_similarities_for_part_of_speech,
)
from language_learn.features.words.schemas import ExampleSentenceCreate, WordCreate, WordUpdate
from language_learn.features.words.service import create_word, delete_word, update_word


def _create(db: Session, word: str, part_of_speech: str = "名詞") -> int:
    w = create_word(db, WordCreate(
        word=word,
        meaning=f"meaning of {word}",
        part_of_speech=part_of_speech,
        example_sentences=[
            ExampleSentenceCreate(sentence_en=f"This is {word}.", sentence_ja="example", order=1)
        ],
    ))
    return w.id


def test_no_similarities_with_fewer_than_two_words(db: Session):
    word_id = _create(db, "alone")
    rows = db.query(WordSimilarity).filter(WordSimilarity.word_id == word_id).all()
    assert rows == []


def test_similarities_created_for_same_part_of_speech_group(db: Session):
    apple_id = _create(db, "apple")
    apricot_id = _create(db, "apricot")

    apple_rows = db.query(WordSimilarity).filter(WordSimilarity.word_id == apple_id).all()
    apricot_rows = db.query(WordSimilarity).filter(WordSimilarity.word_id == apricot_id).all()

    assert {r.similar_word_id for r in apple_rows} == {apricot_id}
    assert {r.similar_word_id for r in apricot_rows} == {apple_id}


def test_different_part_of_speech_words_are_not_linked(db: Session):
    noun_id = _create(db, "apple", part_of_speech="名詞")
    verb_id = _create(db, "run", part_of_speech="動詞")

    noun_rows = db.query(WordSimilarity).filter(WordSimilarity.word_id == noun_id).all()
    verb_rows = db.query(WordSimilarity).filter(WordSimilarity.word_id == verb_id).all()

    assert noun_rows == []
    assert verb_rows == []


def test_similarity_count_capped_at_top_n(db: Session):
    ids = [_create(db, f"word{i:02d}") for i in range(SIMILARITY_TOP_N + 3)]

    rows = db.query(WordSimilarity).filter(WordSimilarity.word_id == ids[0]).all()
    assert len(rows) == SIMILARITY_TOP_N


def test_update_word_part_of_speech_refreshes_both_groups(db: Session):
    noun_a = _create(db, "apple", part_of_speech="名詞")
    noun_b = _create(db, "apricot", part_of_speech="名詞")
    verb_a = _create(db, "run", part_of_speech="動詞")

    update_word(db, noun_a, WordUpdate(meaning="updated", part_of_speech="動詞"))

    # noun グループには apricot のみ残るため類似先がなくなる
    noun_b_rows = db.query(WordSimilarity).filter(WordSimilarity.word_id == noun_b).all()
    assert noun_b_rows == []

    # verb グループに apple(id=noun_a) が加わり run と相互リンクする
    verb_a_rows = db.query(WordSimilarity).filter(WordSimilarity.word_id == verb_a).all()
    assert {r.similar_word_id for r in verb_a_rows} == {noun_a}


def test_delete_word_cleans_up_and_refreshes_remaining_group(db: Session):
    a = _create(db, "apple")
    b = _create(db, "apricot")
    c = _create(db, "avocado")

    delete_word(db, b)

    remaining_similarity_word_ids = {
        row.word_id for row in db.query(WordSimilarity).all()
    } | {row.similar_word_id for row in db.query(WordSimilarity).all()}
    assert b not in remaining_similarity_word_ids

    a_rows = db.query(WordSimilarity).filter(WordSimilarity.word_id == a).all()
    assert {r.similar_word_id for r in a_rows} == {c}


def test_meaning_overlap_demotes_similarity_rank(db: Session):
    """綴りが似ていても意味がほぼ同じ（類義語）候補は、綴りが似ていて意味も異なる候補より低い順位になる。"""
    w = create_word(db, WordCreate(
        word="stark",
        meaning="厳しい、過酷な様子を表す形容詞",
        part_of_speech="形容詞",
        example_sentences=[
            ExampleSentenceCreate(sentence_en="This is stark.", sentence_ja="example", order=1)
        ],
    ))
    synonym = create_word(db, WordCreate(
        word="starz",
        meaning="厳しい、過酷な様子を表す形容詞",
        part_of_speech="形容詞",
        example_sentences=[
            ExampleSentenceCreate(sentence_en="This is starz.", sentence_ja="example", order=1)
        ],
    ))
    different_meaning = create_word(db, WordCreate(
        word="start",
        meaning="物事を開始すること",
        part_of_speech="形容詞",
        example_sentences=[
            ExampleSentenceCreate(sentence_en="This is start.", sentence_ja="example", order=1)
        ],
    ))

    rows = (
        db.query(WordSimilarity)
        .filter(WordSimilarity.word_id == w.id)
        .order_by(WordSimilarity.rank)
        .all()
    )
    ranks = {r.similar_word_id: r.rank for r in rows}
    assert ranks[different_meaning.id] < ranks[synonym.id]


def test_recompute_is_idempotent_delete_then_insert(db: Session):
    _create(db, "apple")
    _create(db, "apricot")

    recompute_similarities_for_part_of_speech(db, "名詞")
    db.commit()
    count_after_first = db.query(WordSimilarity).count()

    recompute_similarities_for_part_of_speech(db, "名詞")
    db.commit()
    count_after_second = db.query(WordSimilarity).count()

    assert count_after_first == count_after_second
