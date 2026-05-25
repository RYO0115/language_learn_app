# ストリーク機能の Pydantic スキーマ定義
from datetime import date

from pydantic import BaseModel, ConfigDict, Field


class StudyRecordResponse(BaseModel):
    """学習記録レスポンススキーマ。"""
    model_config = ConfigDict(from_attributes=True)

    id: int
    study_date: date
    words_studied: int
    quiz_completed: int


class StreakInfo(BaseModel):
    """ストリーク集計情報スキーマ。"""
    current_streak: int = Field(..., description="現在の連続学習日数")
    longest_streak: int = Field(..., description="過去最長連続学習日数")
    total_days: int = Field(..., description="累計学習日数")
    today_studied: bool = Field(..., description="今日学習したかどうか")
