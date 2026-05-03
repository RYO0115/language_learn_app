# アプリケーション固有の例外クラスを定義するモジュール
# HTTP レイヤーに依存せず、ビジネスロジック層で発生する例外を表現する


class AppError(Exception):
    """アプリケーション例外の基底クラス。"""
    pass


class DuplicateWordError(AppError):
    """同じ単語がすでに登録済みの場合に送出する例外。"""
    pass


class WordNotFoundError(AppError):
    """指定した単語が見つからない場合に送出する例外。"""
    pass


class QuizSessionError(AppError):
    """クイズセッション操作でエラーが発生した場合に送出する例外。"""
    pass


class AIServiceError(AppError):
    """AI サービス（Claude API）の呼び出しに失敗した場合に送出する例外。"""
    pass


class ExportImportError(AppError):
    """エクスポート/インポート処理でエラーが発生した場合に送出する例外。"""
    pass
