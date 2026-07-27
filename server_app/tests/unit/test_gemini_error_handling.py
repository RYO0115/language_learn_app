# Gemini プロバイダーの HTTP エラーマッピングを検証する。
# 429（クォータ超過）と 503（overloaded / 一時的利用不可）で、UI 越しには
# 再現しづらいエラー種別を、正しい例外へ変換できることを決定的に確認する。
import pytest
from google.genai import errors as genai_errors

from language_learn.core.exceptions import (
    AIRateLimitError,
    AIServiceError,
    AIServiceUnavailableError,
)
from language_learn.config import settings
from language_learn.features.ai.providers.gemini import GeminiProvider


def _api_error(code: int, status: str, retry_delay: str | None = None) -> genai_errors.APIError:
    """指定コード・status・RetryInfo を持つ APIError を組み立てる。"""
    details: list[dict] = []
    if retry_delay is not None:
        details.append(
            {"@type": "type.googleapis.com/google.rpc.RetryInfo", "retryDelay": retry_delay}
        )
    return genai_errors.APIError(
        code,
        {"error": {"code": code, "status": status, "message": "boom", "details": details}},
        None,
    )


@pytest.fixture
def _patch_client(monkeypatch):
    """generate_content が任意の例外を送出するよう genai.Client を差し替えるファクトリを返す。"""

    def _install(raised: Exception) -> None:
        monkeypatch.setattr(settings, "google_api_key", "dummy-key")

        class _FakeModels:
            def generate_content(self, *args, **kwargs):
                raise raised

        class _FakeClient:
            def __init__(self, *args, **kwargs):
                self.models = _FakeModels()

        monkeypatch.setattr(
            "language_learn.features.ai.providers.gemini.genai.Client", _FakeClient
        )

    return _install


def test_503_raises_service_unavailable_with_retry(_patch_client):
    """503 UNAVAILABLE は AIServiceUnavailableError となり retry_after を保持する。"""
    _patch_client(_api_error(503, "UNAVAILABLE", retry_delay="12s"))

    with pytest.raises(AIServiceUnavailableError) as exc:
        GeminiProvider().generate_word_info("house")

    assert exc.value.retry_after_seconds == 12.0
    # レート制限とは別種別（overloaded）として扱われること
    assert not isinstance(exc.value, AIRateLimitError)


def test_429_raises_rate_limit_error(_patch_client):
    """429 は従来どおり AIRateLimitError にマッピングされる（リグレッション防止）。"""
    _patch_client(_api_error(429, "RESOURCE_EXHAUSTED", retry_delay="7s"))

    with pytest.raises(AIRateLimitError) as exc:
        GeminiProvider().generate_word_info("house")

    assert exc.value.retry_after_seconds == 7.0


def test_other_api_error_raises_generic_service_error(_patch_client):
    """429/503 以外の APIError は汎用の AIServiceError になる。"""
    _patch_client(_api_error(400, "INVALID_ARGUMENT"))

    with pytest.raises(AIServiceError) as exc:
        GeminiProvider().generate_word_info("house")

    assert not isinstance(exc.value, (AIRateLimitError, AIServiceUnavailableError))
