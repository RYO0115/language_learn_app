# SQLAlchemy の宣言的ベースと共通フィールド Mixin を定義するモジュール
from datetime import datetime, timezone

from sqlalchemy import DateTime
from sqlalchemy.orm import DeclarativeBase, MappedColumn, mapped_column


class Base(DeclarativeBase):
    """全モデル共通の DeclarativeBase。テーブル定義はこのクラスを継承して作成する。"""
    pass


class TimestampMixin:
    """作成日時・更新日時を共通で持つ Mixin。各モデルに継承させる。"""

    # レコード作成時に自動設定
    created_at: MappedColumn[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False,
    )
    # レコード更新時に自動更新
    updated_at: MappedColumn[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        nullable=False,
    )
