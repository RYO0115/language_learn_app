# 単語テキストの正規化（normalize_word_text）と、それに依存する重複チェック・検索の
# 挙動を in-memory DB で検証する。
# iPhone のキーボードが末尾に付与しうるゼロ幅文字・空白で「見た目が同じ単語」が
# 別単語として扱われ、重複登録の見逃しや検索ミスが起きないことを保証する。
import pytest
from sqlalchemy.orm import Session

from language_learn.core.exceptions import DuplicateWordError

# quiz モデルを import してメタデータに登録しておく（list_words / create_word が参照するため）
from language_learn.features.quiz.models import QuizAnswer, WordSimilarity  # noqa: F401
from language_learn.features.words.schemas import WordCreate
from language_learn.features.words.service import (
    create_word,
    get_word_by_text,
    list_words,
    normalize_word_text,
)

# iPhone 等が末尾に付与しうるゼロ幅文字の例
ZERO_WIDTH_SPACE = "\u200b"
BOM = "\ufeff"


def _create(db: Session, word: str):
    return create_word(db, WordCreate(word=word, meaning="りんご"))


def test_normalize_removes_trailing_space():
    assert normalize_word_text("apple ") == "apple"
    assert normalize_word_text("  apple  ") == "apple"


def test_normalize_removes_zero_width_and_invisible_chars():
    assert normalize_word_text(f"apple{ZERO_WIDTH_SPACE}") == "apple"
    assert normalize_word_text(f"apple{BOM} ") == "apple"
    assert normalize_word_text(f"{ZERO_WIDTH_SPACE}apple{ZERO_WIDTH_SPACE}") == "apple"


def test_normalize_collapses_internal_whitespace():
    assert normalize_word_text("ice   cream") == "ice cream"


def test_normalize_empty_and_whitespace_only():
    assert normalize_word_text("") == ""
    assert normalize_word_text("   ") == ""
    assert normalize_word_text(ZERO_WIDTH_SPACE) == ""


def test_create_word_detects_duplicate_with_trailing_space(db: Session):
    _create(db, "apple")
    with pytest.raises(DuplicateWordError):
        _create(db, "apple ")


def test_create_word_detects_duplicate_with_trailing_zero_width(db: Session):
    # iPhone が末尾に挿入するゼロ幅文字付きでも重複として検出されること
    _create(db, "apple")
    with pytest.raises(DuplicateWordError):
        _create(db, f"apple{ZERO_WIDTH_SPACE}")


def test_create_word_stores_normalized_text(db: Session):
    word = _create(db, f"  apple{ZERO_WIDTH_SPACE} ")
    assert word.word == "apple"


def test_get_word_by_text_normalizes(db: Session):
    _create(db, "apple")
    assert get_word_by_text(db, f"apple{ZERO_WIDTH_SPACE}") is not None
    assert get_word_by_text(db, "APPLE ") is not None
    assert get_word_by_text(db, ZERO_WIDTH_SPACE) is None


def test_list_words_search_ignores_trailing_whitespace(db: Session):
    _create(db, "apple")
    assert [w.word for w in list_words(db, search="apple ")] == ["apple"]


def test_list_words_search_ignores_zero_width(db: Session):
    _create(db, "apple")
    assert [w.word for w in list_words(db, search=f"apple{ZERO_WIDTH_SPACE}")] == ["apple"]
