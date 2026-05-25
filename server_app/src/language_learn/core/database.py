# データベース接続・セッション管理モジュール
# SQLAlchemy エンジンとセッションファクトリを提供し、FastAPI の依存注入で使用する
from pathlib import Path
from typing import Generator

from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

from language_learn.config import settings

# data ディレクトリが存在しない場合は作成（SQLite ファイルが置けるように）
db_path = Path(settings.database_url.replace("sqlite:///", ""))
db_path.parent.mkdir(parents=True, exist_ok=True)

# SQLAlchemy エンジン（SQLite はスレッドセーフにするため check_same_thread=False を設定）
engine = create_engine(
    settings.database_url,
    connect_args={"check_same_thread": False},
    echo=settings.debug,
)

# セッションファクトリ
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db() -> Generator[Session, None, None]:
    """FastAPI 依存注入用 DB セッションジェネレーター。リクエスト毎にセッションを生成・クローズする。"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
