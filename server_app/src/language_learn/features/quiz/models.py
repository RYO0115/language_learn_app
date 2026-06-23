# クイズ機能の SQLAlchemy モデル定義
# QuizSession（セッション）・QuizSessionWord（出題単語）・QuizAnswer（回答）・
# WordSimilarity（穴埋め3択の選択肢候補事前計算）・QuizSessionWordChoice（穴埋め3択の選択肢）を定義する
from datetime import datetime

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, String
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
    # クイズの種類（"meaning": 意味確認テスト / "fill_blank": 例文穴埋め3択テスト）
    quiz_type: Mapped[str] = mapped_column(String(20), nullable=False, default="meaning")
    # 穴埋め対象の例文 ID（quiz_type == "fill_blank" の場合のみ使用）
    example_sentence_id: Mapped[int | None] = mapped_column(
        Integer, ForeignKey("example_sentences.id", ondelete="CASCADE"), nullable=True
    )

    session: Mapped["QuizSession"] = relationship("QuizSession", back_populates="session_words")
    # 文字列参照で循環インポートを回避
    word: Mapped["Word"] = relationship("Word")  # type: ignore[name-defined]  # noqa: F821
    # 穴埋め3択テストの選択肢（quiz_type == "fill_blank" の場合のみ使用）
    choices: Mapped[list["QuizSessionWordChoice"]] = relationship(
        "QuizSessionWordChoice",
        back_populates="session_word",
        cascade="all, delete-orphan",
    )


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
    word: Mapped["Word"] = relationship("Word")  # type: ignore[name-defined]  # noqa: F821


class WordSimilarity(Base):
    """類似単語テーブル。穴埋め3択テストの誤答選択肢候補を事前計算して保持する。

    同じ品詞の単語同士で類似度を計算し、word_id ごとに似ている順（rank 昇順）で
    上位数件を保存する。出題時はここからランダムに誤答候補を抽出するため、
    毎回類似度を再計算する必要がなく処理コストを抑えられる。
    """

    __tablename__ = "word_similarities"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    # 対象単語 ID
    word_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("words.id", ondelete="CASCADE"), nullable=False, index=True
    )
    # 似ている単語の ID（誤答選択肢候補）
    similar_word_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("words.id", ondelete="CASCADE"), nullable=False
    )
    # 似ている順（小さいほど似ている）
    rank: Mapped[int] = mapped_column(Integer, nullable=False)


class QuizSessionWordChoice(Base):
    """穴埋め3択テストの選択肢テーブル。1問あたり3件（正解1件+誤答2件）を保持する。"""

    __tablename__ = "quiz_session_word_choices"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    # 所属する出題単語（QuizSessionWord）
    session_word_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("quiz_session_words.id", ondelete="CASCADE"), nullable=False, index=True
    )
    # 選択肢の単語 ID
    word_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("words.id", ondelete="CASCADE"), nullable=False
    )
    # 正解かどうか
    is_correct: Mapped[bool] = mapped_column(Boolean, nullable=False)

    session_word: Mapped["QuizSessionWord"] = relationship(
        "QuizSessionWord", back_populates="choices"
    )
    # 文字列参照で循環インポートを回避
    word: Mapped["Word"] = relationship("Word")  # type: ignore[name-defined]  # noqa: F821
