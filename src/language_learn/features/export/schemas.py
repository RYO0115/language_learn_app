# エクスポート/インポート機能の Pydantic スキーマ定義
from pydantic import BaseModel, Field


class ImportResult(BaseModel):
    """インポート処理の結果スキーマ。"""
    imported_count: int = Field(default=0, description="新規インポートした単語数")
    skipped_count: int = Field(default=0, description="重複でスキップした単語数")
    error_count: int = Field(default=0, description="エラーが発生した単語数")
    errors: list[str] = Field(default_factory=list, description="エラー詳細メッセージ")
