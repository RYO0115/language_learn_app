# Anthropic Claude API プロバイダー実装
# JSON プロンプト方式で単語情報を生成する
import json
import re

import anthropic

from language_learn.config import settings
from language_learn.core.exceptions import AIServiceError
from language_learn.features.ai.providers.base import BaseAIProvider
from language_learn.features.ai.schemas import AIGenerateResponse, ExampleSentenceAI

# Claude に渡すプロンプト（JSON 形式で返すよう指示する）
_PROMPT = """あなたは英語学習アシスタントです。日本語話者が英語を学習するために、以下の英単語について詳細な情報を提供してください。

英単語: {word}

以下の JSON 形式のみで回答してください（説明文や前置きは不要です）:
{{
  "reading": "発音記号（IPA 表記、例: /ˈwɔːtər/）",
  "part_of_speech": "品詞（日本語表記、例: 名詞・動詞・形容詞・副詞・前置詞・接続詞・間投詞など）",
  "meaning": "日本語での意味と説明（複数の意味がある場合は主要なものをすべて記載）",
  "example_sentences": [
    {{
      "sentence_en": "その単語を使った自然な英語例文1",
      "sentence_ja": "例文1の日本語訳"
    }},
    {{
      "sentence_en": "異なる文脈での英語例文2（例文1と異なるシチュエーション）",
      "sentence_ja": "例文2の日本語訳"
    }}
  ]
}}"""


class ClaudeProvider(BaseAIProvider):
    """Anthropic Claude API を使った単語情報生成プロバイダー。"""

    def generate_word_info(self, word: str) -> AIGenerateResponse:
        """Claude API を呼び出して単語情報を生成する。"""
        if not settings.anthropic_api_key:
            raise AIServiceError(
                "Anthropic API キーが設定されていません。.env の ANTHROPIC_API_KEY を確認してください。"
            )

        client = anthropic.Anthropic(api_key=settings.anthropic_api_key)

        try:
            message = client.messages.create(
                model="claude-haiku-4-5-20251001",
                max_tokens=1024,
                messages=[{"role": "user", "content": _PROMPT.format(word=word)}],
            )
        except anthropic.APIError as e:
            raise AIServiceError(f"Claude API の呼び出しに失敗しました: {e}") from e

        raw_text = message.content[0].text.strip()

        # ```json ... ``` 形式にも対応してコードブロックを除去する
        json_match = re.search(r"```(?:json)?\s*([\s\S]*?)```", raw_text)
        if json_match:
            raw_text = json_match.group(1).strip()

        try:
            data = json.loads(raw_text)
        except json.JSONDecodeError as e:
            raise AIServiceError(f"Claude の応答を JSON として解析できませんでした: {e}") from e

        example_sentences = [
            ExampleSentenceAI(
                sentence_en=sent.get("sentence_en", ""),
                sentence_ja=sent.get("sentence_ja", ""),
            )
            for sent in data.get("example_sentences", [])
        ]

        return AIGenerateResponse(
            reading=data.get("reading", ""),
            part_of_speech=data.get("part_of_speech", ""),
            meaning=data.get("meaning", ""),
            example_sentences=example_sentences,
        )
