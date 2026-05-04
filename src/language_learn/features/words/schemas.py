# 単語帳機能の Pydantic スキーマ定義
# API リクエスト・レスポンスの型バリデーションに使用する
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


# --- 例文スキーマ ---

class ExampleSentenceCreate(BaseModel):
    """例文作成リクエストスキーマ。"""
    sentence_en: str = Field(..., description="英語例文")
    sentence_ja: str = Field(..., description="日本語訳")
    order: int = Field(default=1, ge=1, description="表示順序")
    label: str | None = Field(default=None, description="この例文が属する品詞ラベル（例: 名詞・動詞）")


class ExampleSentenceResponse(BaseModel):
    """例文レスポンススキーマ。"""
    model_config = ConfigDict(from_attributes=True)

    id: int
    sentence_en: str
    sentence_ja: str
    order: int
    label: str | None = None


# --- 出典情報スキーマ ---

# 出典の種類（将来追加可能なリテラル型）
SourceType = Literal["book", "website", "video", "other"]


class WordSourceCreate(BaseModel):
    """出典情報作成リクエストスキーマ。"""
    source_type: SourceType = Field(default="other", description="出典の種類")
    title: str | None = Field(default=None, description="書籍名・サイト名など")
    url: str | None = Field(default=None, description="URL")
    page_number: str | None = Field(default=None, description="ページ数")
    detail: str | None = Field(default=None, description="その他詳細")


class WordSourceResponse(BaseModel):
    """出典情報レスポンススキーマ。"""
    model_config = ConfigDict(from_attributes=True)

    id: int
    source_type: str
    title: str | None
    url: str | None
    page_number: str | None
    detail: str | None
    created_at: datetime


# --- 単語スキーマ ---

class WordCreate(BaseModel):
    """単語作成リクエストスキーマ。"""
    word: str = Field(..., min_length=1, max_length=100, description="英単語")
    reading: str | None = Field(default=None, description="発音記号")
    meaning: str = Field(..., min_length=1, description="日本語の意味")
    part_of_speech: str | None = Field(default=None, description="品詞")
    example_sentences: list[ExampleSentenceCreate] = Field(
        default_factory=list, description="例文リスト"
    )
    source: WordSourceCreate | None = Field(default=None, description="出典情報")


class WordUpdate(BaseModel):
    """単語更新リクエストスキーマ（部分更新対応）。"""
    reading: str | None = None
    meaning: str | None = None
    part_of_speech: str | None = None
    example_sentences: list[ExampleSentenceCreate] | None = None
    source: WordSourceCreate | None = None


class WordResponse(BaseModel):
    """単語詳細レスポンススキーマ。"""
    model_config = ConfigDict(from_attributes=True)

    id: int
    word: str
    reading: str | None
    meaning: str
    part_of_speech: str | None
    example_sentences: list[ExampleSentenceResponse]
    sources: list[WordSourceResponse]
    created_at: datetime
    updated_at: datetime
    # クイズ正答率（DB に持たず計算値として付加）
    accuracy: float | None = None
    quiz_count: int = 0


class WordListItem(BaseModel):
    """単語一覧用の軽量レスポンススキーマ。"""
    model_config = ConfigDict(from_attributes=True)

    id: int
    word: str
    reading: str | None
    meaning: str
    part_of_speech: str | None
    created_at: datetime
    accuracy: float | None = None
    quiz_count: int = 0


# ソート種別
SortBy = Literal["created_at_desc", "created_at_asc", "word_asc", "word_desc", "accuracy_asc"]
