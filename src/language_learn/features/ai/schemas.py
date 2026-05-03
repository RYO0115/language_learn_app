# AI 連携機能の Pydantic スキーマ定義
# Claude API への入力・出力の型を定義する
from pydantic import BaseModel, Field


class AIGenerateRequest(BaseModel):
    """単語情報生成リクエスト。"""
    word: str = Field(..., min_length=1, description="情報を生成する英単語")


class ExampleSentenceAI(BaseModel):
    """AI が生成した例文（英語 + 日本語訳）。"""
    sentence_en: str = Field(..., description="英語例文")
    sentence_ja: str = Field(..., description="日本語訳")


class AIGenerateResponse(BaseModel):
    """Claude API が返す単語情報。フォームに自動入力するために使用する。"""
    reading: str = Field(default="", description="発音記号（IPA 表記）")
    part_of_speech: str = Field(default="", description="品詞（日本語表記）")
    meaning: str = Field(..., description="日本語での意味・説明")
    example_sentences: list[ExampleSentenceAI] = Field(
        default_factory=list, description="例文リスト（2件）"
    )
