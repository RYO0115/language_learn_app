# Google Gemini API プロバイダー実装
# response_schema による構造化出力で複数品詞に対応する
import re

from google import genai
from google.genai import errors as genai_errors
from google.genai import types

from language_learn.config import settings
from language_learn.core.exceptions import (
    AIRateLimitError,
    AIServiceError,
    AIServiceUnavailableError,
)
from language_learn.features.ai.providers.base import BaseAIProvider
from language_learn.features.ai.schemas import AIGenerateResponse

# response_schema が JSON 構造を制御するため、プロンプトは意図の説明に集中する
_PROMPT = """あなたは英語学習アシスタントです。日本語話者が英語を学習するために、以下の英単語について詳細な情報を提供してください。

英単語: {word}

【重要】その単語が名詞・動詞・形容詞など複数の品詞として使われる場合は、それぞれの品詞について別々に情報を提供してください。
例えば "house" であれば「名詞: 家」と「動詞: 収容する」の両方を提供してください。

各品詞について以下を提供してください:
- 品詞名（日本語表記: 名詞・動詞・形容詞・副詞・前置詞・接続詞など）
- その品詞における日本語の意味と説明
- その品詞の使い方を示す自然な英語例文を 2 件（それぞれ日本語訳付き）

発音記号は IPA 表記で 1 つ提供してください。"""


def _extract_retry_delay(error: genai_errors.APIError) -> float | None:
    """APIError の details から RetryInfo の retryDelay（秒）を取り出す。"""
    details = getattr(error, "details", None) or {}
    for item in details.get("error", {}).get("details", []):
        retry_delay = item.get("retryDelay")
        if retry_delay:
            match = re.match(r"([\d.]+)s", retry_delay)
            if match:
                return float(match.group(1))
    return None


class GeminiProvider(BaseAIProvider):
    """Google Gemini API を使った単語情報生成プロバイダー。

    response_schema に Pydantic モデルを渡すことで複数品詞を含む
    構造化レスポンスを JSON 後処理なしに取得できる。
    """

    def generate_word_info(self, word: str) -> AIGenerateResponse:
        """Gemini API を呼び出して単語情報を生成する。"""
        if not settings.google_api_key:
            raise AIServiceError(
                "Google API キーが設定されていません。.env の GOOGLE_API_KEY を確認してください。"
            )

        client = genai.Client(api_key=settings.google_api_key)

        try:
            response = client.models.generate_content(
                model=settings.gemini_model,
                contents=_PROMPT.format(word=word),
                config=types.GenerateContentConfig(
                    response_mime_type="application/json",
                    response_schema=AIGenerateResponse,
                ),
            )
        except genai_errors.APIError as e:
            if e.code == 429:
                raise AIRateLimitError(
                    "Gemini API のクォータ（利用上限）を超えました。"
                    "しばらく時間をおいてから再試行してください。",
                    retry_after_seconds=_extract_retry_delay(e),
                ) from e
            if e.code == 503:
                raise AIServiceUnavailableError(
                    "Gemini API が一時的に混雑しており利用できません（overloaded）。"
                    "しばらく時間をおいてから再試行してください。",
                    retry_after_seconds=_extract_retry_delay(e),
                ) from e
            raise AIServiceError(f"Gemini API の呼び出しに失敗しました: {e}") from e
        except Exception as e:
            raise AIServiceError(f"Gemini API の呼び出しに失敗しました: {e}") from e

        if not response.text:
            raise AIServiceError("Gemini API から空のレスポンスが返されました。")

        try:
            return AIGenerateResponse.model_validate_json(response.text)
        except Exception as e:
            raise AIServiceError(f"Gemini のレスポンスの解析に失敗しました: {e}") from e
