# テスト専用 AI プロバイダー実装
# 実 API を呼ばずに固定データを返すことで、UI テストを決定的・低コストに実行できるようにする
from language_learn.config import settings
from language_learn.core.exceptions import AIRateLimitError
from language_learn.features.ai.providers.base import BaseAIProvider
from language_learn.features.ai.schemas import AIGenerateResponse, ExampleSentenceAI, WordMeaningAI


class StubProvider(BaseAIProvider):
    """テスト専用のダミー AI プロバイダー。

    AI_PROVIDER=stub を設定した場合のみ使用される。
    AI_STUB_FORCE_RATE_LIMIT=1 の場合は AIRateLimitError を強制発生させ、
    429 系の UI 挙動（リトライ秒数表示・クールダウン）をテストできるようにする。
    """

    def generate_word_info(self, word: str) -> AIGenerateResponse:
        if settings.ai_stub_force_rate_limit:
            raise AIRateLimitError(
                "（テスト用）AI のレート制限をシミュレートしています。",
                retry_after_seconds=5,
            )

        return AIGenerateResponse(
            reading="/stʌb/",
            word_meanings=[
                WordMeaningAI(
                    part_of_speech="名詞",
                    meaning=f"「{word}」のテスト用ダミー意味です。",
                    example_sentences=[
                        ExampleSentenceAI(
                            sentence_en=f"This is a stub example sentence for {word}.",
                            sentence_ja=f"これは {word} のテスト用例文1です。",
                        ),
                        ExampleSentenceAI(
                            sentence_en=f"Another stub sentence using {word}.",
                            sentence_ja=f"これは {word} のテスト用例文2です。",
                        ),
                    ],
                ),
            ],
        )
