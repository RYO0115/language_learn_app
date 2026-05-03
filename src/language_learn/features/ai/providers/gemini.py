# Google Gemini API プロバイダー実装
# response_schema による構造化出力で JSON 解析を不要にする
from google import genai
from google.genai import types

from language_learn.config import settings
from language_learn.core.exceptions import AIServiceError
from language_learn.features.ai.providers.base import BaseAIProvider
from language_learn.features.ai.schemas import AIGenerateResponse

# Gemini に渡すプロンプト（JSON スキーマは response_schema で自動制御されるため
# プロンプト内での JSON 形式の指定は不要）
_PROMPT = """あなたは英語学習アシスタントです。日本語話者が英語を学習するために、以下の英単語について詳細な情報を提供してください。

英単語: {word}

以下の情報を正確に提供してください:
- 発音記号（IPA 表記）
- 品詞（日本語表記: 名詞・動詞・形容詞・副詞・前置詞・接続詞・間投詞など）
- 日本語での意味と説明（複数の意味がある場合は主要なものをすべて記載）
- 異なるシチュエーションの自然な英語例文を 2 件（それぞれ日本語訳付き）"""


class GeminiProvider(BaseAIProvider):
    """Google Gemini API を使った単語情報生成プロバイダー。

    response_schema に Pydantic モデルを渡すことで、
    JSON の後処理なしに型安全なレスポンスを取得できる。
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
                    # Pydantic モデルを response_schema に渡すと JSON を自動的に構造化して返す
                    response_mime_type="application/json",
                    response_schema=AIGenerateResponse,
                ),
            )
        except Exception as e:
            raise AIServiceError(f"Gemini API の呼び出しに失敗しました: {e}") from e

        if not response.text:
            raise AIServiceError("Gemini API から空のレスポンスが返されました。")

        try:
            return AIGenerateResponse.model_validate_json(response.text)
        except Exception as e:
            raise AIServiceError(f"Gemini のレスポンスの解析に失敗しました: {e}") from e
