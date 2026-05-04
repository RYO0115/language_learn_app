# AI 連携機能の Pydantic スキーマ定義
# Claude API / Gemini API への入力・出力の型を定義する
from pydantic import BaseModel, Field


class AIGenerateRequest(BaseModel):
    """単語情報生成リクエスト。"""
    word: str = Field(..., min_length=1, description="情報を生成する英単語")


class ExampleSentenceAI(BaseModel):
    """AI が生成した例文（英語 + 日本語訳）。"""
    sentence_en: str = Field(..., description="英語例文")
    sentence_ja: str = Field(..., description="日本語訳")


class WordMeaningAI(BaseModel):
    """品詞ごとの意味・例文セット。複数品詞を持つ単語はこのオブジェクトが複数返される。"""
    part_of_speech: str = Field(..., description="品詞（日本語表記: 名詞・動詞・形容詞など）")
    meaning: str = Field(..., description="この品詞における日本語の意味・説明")
    example_sentences: list[ExampleSentenceAI] = Field(
        default_factory=list, description="この品詞の例文リスト（2件）"
    )


class AIGenerateResponse(BaseModel):
    """Claude / Gemini API が返す単語情報。品詞ごとに意味と例文をまとめた構造。"""
    reading: str = Field(default="", description="発音記号（IPA 表記）")
    word_meanings: list[WordMeaningAI] = Field(
        default_factory=list,
        description="品詞ごとの意味リスト。複数品詞を持つ単語は複数要素になる。"
    )
