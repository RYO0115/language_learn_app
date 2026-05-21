# AI プロバイダー抽象基底クラス
# 新しい AI プロバイダーを追加する場合はこのクラスを継承して実装する
from abc import ABC, abstractmethod

from language_learn.features.ai.schemas import AIGenerateResponse


class BaseAIProvider(ABC):
    """AI プロバイダーの共通インターフェース。

    新しいプロバイダーを追加する手順:
    1. このクラスを継承したクラスを providers/ 配下に作成する
    2. generate_word_info() を実装する
    3. service.py の get_ai_provider() にプロバイダー名と対応クラスを追加する
    4. config.py の ai_provider の Literal 型に名前を追加する
    """

    @abstractmethod
    def generate_word_info(self, word: str) -> AIGenerateResponse:
        """英単語から意味・発音・品詞・例文を生成して返す。

        Args:
            word: 情報を生成する英単語

        Returns:
            AIGenerateResponse: 生成された単語情報

        Raises:
            AIServiceError: API 呼び出し失敗・レスポンス解析失敗時
        """
        ...
