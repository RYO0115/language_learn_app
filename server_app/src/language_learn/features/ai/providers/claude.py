# Anthropic Claude API プロバイダー実装
# JSON プロンプト方式で単語情報を生成する（複数品詞に対応）
import json
import re

import anthropic

from language_learn.config import settings
from language_learn.core.exceptions import AIRateLimitError, AIServiceError
from language_learn.features.ai.providers.base import BaseAIProvider
from language_learn.features.ai.schemas import AIGenerateResponse, ExampleSentenceAI, WordMeaningAI

# 複数品詞に対応したプロンプト
_PROMPT = """あなたは英語学習アシスタントです。日本語話者が英語を学習するために、以下の英単語について詳細な情報を提供してください。

英単語: {word}

重要: その単語が名詞・動詞・形容詞など複数の品詞として使われる場合は、それぞれの品詞について別々に情報を提供してください。

以下の JSON 形式のみで回答してください（説明文や前置きは不要です）:
{{
  "reading": "発音記号（IPA 表記、例: /haʊs/）",
  "word_meanings": [
    {{
      "part_of_speech": "品詞1（日本語表記: 名詞・動詞・形容詞・副詞など）",
      "meaning": "この品詞における日本語の意味と説明",
      "example_sentences": [
        {{
          "sentence_en": "この品詞を使った自然な英語例文1",
          "sentence_ja": "例文1の日本語訳"
        }},
        {{
          "sentence_en": "この品詞を使った異なる文脈の英語例文2",
          "sentence_ja": "例文2の日本語訳"
        }}
      ]
    }},
    {{
      "part_of_speech": "品詞2（他の品詞がある場合のみ追加）",
      "meaning": "この品詞における日本語の意味と説明",
      "example_sentences": [
        {{
          "sentence_en": "この品詞を使った自然な英語例文1",
          "sentence_ja": "例文1の日本語訳"
        }},
        {{
          "sentence_en": "この品詞を使った異なる文脈の英語例文2",
          "sentence_ja": "例文2の日本語訳"
        }}
      ]
    }}
  ]
}}

品詞が1つしかない場合は word_meanings の要素を1つだけにしてください。"""


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
                max_tokens=2048,
                messages=[{"role": "user", "content": _PROMPT.format(word=word)}],
            )
        except anthropic.RateLimitError as e:
            retry_after = None
            retry_after_header = e.response.headers.get("retry-after")
            if retry_after_header:
                try:
                    retry_after = float(retry_after_header)
                except ValueError:
                    retry_after = None
            raise AIRateLimitError(
                "Claude API のレート制限・クォータ（利用上限）を超えました。"
                "しばらく時間をおいてから再試行してください。",
                retry_after_seconds=retry_after,
            ) from e
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

        word_meanings = []
        for m in data.get("word_meanings", []):
            examples = [
                ExampleSentenceAI(
                    sentence_en=s.get("sentence_en", ""),
                    sentence_ja=s.get("sentence_ja", ""),
                )
                for s in m.get("example_sentences", [])
            ]
            word_meanings.append(WordMeaningAI(
                part_of_speech=m.get("part_of_speech", ""),
                meaning=m.get("meaning", ""),
                example_sentences=examples,
            ))

        return AIGenerateResponse(
            reading=data.get("reading", ""),
            word_meanings=word_meanings,
        )
