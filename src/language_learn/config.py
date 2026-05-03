# アプリケーション全体の設定を管理するモジュール
# 環境変数（.env ファイル）から設定を読み込む
from pathlib import Path
from pydantic_settings import BaseSettings, SettingsConfigDict

# プロジェクトルートディレクトリ
BASE_DIR = Path(__file__).resolve().parent.parent.parent


class Settings(BaseSettings):
    """アプリ設定クラス。環境変数または .env ファイルから値を読み込む。"""

    # アプリ基本設定
    app_name: str = "Language Learn App"
    debug: bool = False

    # データベース設定
    database_url: str = f"sqlite:///{BASE_DIR}/data/language_learn.db"

    # Anthropic API 設定
    anthropic_api_key: str = ""

    # クイズ設定
    quiz_question_count: int = 20

    model_config = SettingsConfigDict(
        env_file=str(BASE_DIR / ".env"),
        env_file_encoding="utf-8",
        extra="ignore",
    )


# アプリ全体で使うシングルトン設定インスタンス
settings = Settings()
