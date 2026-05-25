# クイズ機能の SQLAlchemy モデル定義
# QuizSession（セッション）・QuizSessionWord（出題単語）・QuizAnswer（回答）を定義する
from datetime import datetime

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship

from language_learn.core.base_model import Base


class QuizSession(Base):
    """クイズセッションテーブル。1回のテスト実施を表す。"""

    __tablename__ = "quiz_sessions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    # セッション開始日時
    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    # セッション完了日時（未完了は NULL）
    completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    # このセッションの出題単語リスト
    session_words: Mapped[list["QuizSessionWord"]] = relationship(
        "QuizSessionWord",
        back_populates="session",
        cascade="all, delete-orphan",
        order_by="QuizSessionWord.order",
    )
    # このセッションの回答履歴
    answers: Mapped[list["QuizAnswer"]] = relationship(
        "QuizAnswer",
        back_populates="session",
        cascade="all, delete-orphan",
    )


class QuizSessionWord(Base):
    """クイズセッションの出題単語テーブル。どの単語を何番目に出題するかを管理する。"""

    __tablename__ = "quiz_session_words"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    # 所属するセッション
    session_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("quiz_sessions.id", ondelete="CASCADE"), nullable=False, index=True
    )
    # 出題する単語 ID
    word_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("words.id", ondelete="CASCADE"), nullable=False
    )
    # 出題順（1番目から開始）
    order: Mapped[int] = mapped_column(Integer, nullable=False)
    # 回答済みかどうか
    is_answered: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)

    session: Mapped["QuizSession"] = relationship("QuizSession", back_populates="session_words")
    # 文字列参照で循環インポートを回避
    word: Mapped["Word"] = relationship("Word")  # type: ignore[name-defined]


class QuizAnswer(Base):
    """クイズ回答テーブル。各単語への回答結果を記録する。"""

    __tablename__ = "quiz_answers"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    # 所属するセッション
    session_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("quiz_sessions.id", ondelete="CASCADE"), nullable=False, index=True
    )
    # 回答した単語 ID（正答率計算に使用）
    word_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("words.id", ondelete="CASCADE"), nullable=False, index=True
    )
    # 覚えている(True) / 覚えていない(False)
    is_correct: Mapped[bool] = mapped_column(Boolean, nullable=False)
    # 回答日時
    answered_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    session: Mapped["QuizSession"] = relationship("QuizSession", back_populates="answers")
    # 文字列参照で循環インポートを回避
    word: Mapped["Word"] = relationship("Word")  # type: ignore[name-defined]
