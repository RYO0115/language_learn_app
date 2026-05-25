# クイズ機能の Pydantic スキーマ定義
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class QuizAnswerSubmit(BaseModel):
    """クイズ回答送信スキーマ。"""
    word_id: int = Field(..., description="回答した単語の ID")
    is_correct: bool = Field(..., description="覚えている(True) / 覚えていない(False)")


class QuizWordResult(BaseModel):
    """クイズ結果の単語ごとの詳細。"""
    word_id: int
    word: str
    meaning: str
    is_correct: bool


class QuizResultResponse(BaseModel):
    """クイズセッション完了時の結果スキーマ。"""
    session_id: int
    total: int = Field(..., description="出題数")
    correct: int = Field(..., description="覚えていた数")
    incorrect: int = Field(..., description="覚えていなかった数")
    accuracy: float = Field(..., description="正答率（%）")
    wrong_words: list[QuizWordResult] = Field(default_factory=list, description="間違えた単語の一覧")
    completed_at: datetime


class QuizSessionInfo(BaseModel):
    """クイズセッション情報スキーマ。"""
    model_config = ConfigDict(from_attributes=True)

    id: int
    started_at: datetime
    completed_at: datetime | None
    total_questions: int = 0
    answered_count: int = 0
