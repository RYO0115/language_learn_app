# ストリーク機能の SQLAlchemy モデル定義
# StudyRecord: 日単位の学習記録を保持する
from datetime import date

from sqlalchemy import Date, Integer, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from language_learn.core.base_model import Base


class StudyRecord(Base):
    """学習記録テーブル。1日1レコードで学習実績を管理する。"""

    __tablename__ = "study_records"
    __table_args__ = (
        # 同一日付の重複登録を防ぐユニーク制約
        UniqueConstraint("study_date", name="uq_study_records_date"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    # 学習日（1日1レコード）
    study_date: Mapped[date] = mapped_column(Date, nullable=False, unique=True, index=True)
    # その日に学習した単語数
    words_studied: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    # その日に完了したクイズ回数
    quiz_completed: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
