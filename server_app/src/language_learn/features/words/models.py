# 単語帳機能の SQLAlchemy モデル定義
# Word（単語）・ExampleSentence（例文）・WordSource（出典情報）の3テーブルを定義する
from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from language_learn.core.base_model import Base, TimestampMixin


class Word(Base, TimestampMixin):
    """単語テーブル。英単語とその意味・品詞・発音を保持する。"""

    __tablename__ = "words"

    # 主キー
    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    # 英単語（ユニーク制約で重複を防ぐ）
    word: Mapped[str] = mapped_column(String(100), nullable=False, unique=True, index=True)
    # 発音記号（IPA 表記など）
    reading: Mapped[str | None] = mapped_column(String(200), nullable=True)
    # 日本語の意味・説明
    meaning: Mapped[str] = mapped_column(Text, nullable=False)
    # 品詞（名詞・動詞・形容詞など）
    part_of_speech: Mapped[str | None] = mapped_column(String(50), nullable=True)

    # 例文（1単語に複数例文を持てる）
    example_sentences: Mapped[list["ExampleSentence"]] = relationship(
        "ExampleSentence",
        back_populates="word",
        cascade="all, delete-orphan",
        order_by="ExampleSentence.order",
    )
    # 出典情報（1単語に複数の出典を登録可能）
    sources: Mapped[list["WordSource"]] = relationship(
        "WordSource",
        back_populates="word",
        cascade="all, delete-orphan",
    )


class ExampleSentence(Base):
    """例文テーブル。英語例文と日本語訳のペアを保持する。"""

    __tablename__ = "example_sentences"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    # 紐づく単語の ID
    word_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("words.id", ondelete="CASCADE"), nullable=False, index=True
    )
    # 英語例文
    sentence_en: Mapped[str] = mapped_column(Text, nullable=False)
    # 日本語訳
    sentence_ja: Mapped[str] = mapped_column(Text, nullable=False)
    # 順序（1番目・2番目…と表示順を制御）
    order: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    # この例文が属する品詞ラベル（例: 名詞・動詞）。複数品詞を持つ単語で例文をグループ化するために使用する
    label: Mapped[str | None] = mapped_column(String(50), nullable=True)

    word: Mapped["Word"] = relationship("Word", back_populates="example_sentences")


class WordSource(Base):
    """出典情報テーブル。単語をどこで見かけたかを記録する。

    将来的に項目が増える可能性があるため、detail（自由記述）フィールドで柔軟に対応する。
    """

    __tablename__ = "word_sources"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    # 紐づく単語の ID
    word_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("words.id", ondelete="CASCADE"), nullable=False, index=True
    )
    # 出典の種類（book: 書籍, website: ウェブサイト, video: 動画, other: その他）
    source_type: Mapped[str] = mapped_column(String(20), nullable=False, default="other")
    # 書籍名・サイト名・動画タイトルなど
    title: Mapped[str | None] = mapped_column(String(300), nullable=True)
    # URL（ウェブサイト・動画の場合）
    url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    # ページ数・章番号などの位置情報
    page_number: Mapped[str | None] = mapped_column(String(50), nullable=True)
    # その他の詳細情報（自由記述）
    detail: Mapped[str | None] = mapped_column(Text, nullable=True)
    # 登録日時
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False
    )

    word: Mapped["Word"] = relationship("Word", back_populates="sources")
