# AI 連携サービス（ファクトリーパターン）
# 設定ファイルの AI_PROVIDER に応じてプロバイダーを切り替える
# 新しいプロバイダーを追加する場合は providers/ にクラスを追加し、
# get_ai_provider() に分岐を追加するだけでよい
from language_learn.config import settings
from language_learn.core.exceptions import AIServiceError
from language_learn.features.ai.providers.base import BaseAIProvider
from language_learn.features.ai.schemas import AIGenerateResponse


def get_ai_provider() -> BaseAIProvider:
    """設定された AI_PROVIDER に応じてプロバイダーインスタンスを返すファクトリー関数。

    プロバイダーのモジュールは遅延インポートするため、
    未使用のプロバイダーの依存ライブラリがインストールされていなくても動作する。
    """
    provider_name = settings.ai_provider.lower()

    if provider_name == "gemini":
        from language_learn.features.ai.providers.gemini import GeminiProvider
        return GeminiProvider()

    if provider_name == "claude":
        from language_learn.features.ai.providers.claude import ClaudeProvider
        return ClaudeProvider()

    # 設定値が不正な場合（Literal 型で弾かれるが念のため）
    raise AIServiceError(
        f"不明な AI プロバイダー: '{provider_name}'。"
        ".env の AI_PROVIDER に 'claude' または 'gemini' を設定してください。"
    )


def generate_word_info(word: str) -> AIGenerateResponse:
    """英単語の情報を AI で生成して返す。

    使用するプロバイダーは .env の AI_PROVIDER 設定に従う。
    """
    provider = get_ai_provider()
    return provider.generate_word_info(word)
