# UI テスト共通フィクスチャ
# 実際に uvicorn サーバーをサブプロセスで起動し、Playwright のブラウザから操作して検証する
import os
import socket
import subprocess
import sys
import time
import urllib.request
import urllib.error

import pytest


def _free_port() -> int:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(("127.0.0.1", 0))
        return s.getsockname()[1]


def _wait_until_ready(url: str, timeout: float = 30.0) -> None:
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            urllib.request.urlopen(url, timeout=1)
            return
        except (urllib.error.URLError, ConnectionError):
            time.sleep(0.2)
    raise RuntimeError(f"server did not become ready in time: {url}")


@pytest.fixture(scope="session")
def live_server(tmp_path_factory):
    """テスト用 DB・stub AI プロバイダーで uvicorn を起動し、ベース URL を返す。"""
    port = _free_port()
    db_path = tmp_path_factory.mktemp("db") / "test.db"

    env = os.environ.copy()
    env["DATABASE_URL"] = f"sqlite:///{db_path}"
    env["AI_PROVIDER"] = "stub"
    env.pop("AI_STUB_FORCE_RATE_LIMIT", None)

    process = subprocess.Popen(
        [sys.executable, "-m", "uvicorn", "language_learn.main:app", "--port", str(port)],
        env=env,
        cwd=os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
    )

    base_url = f"http://127.0.0.1:{port}"
    try:
        _wait_until_ready(base_url + "/")
        yield base_url
    finally:
        process.terminate()
        process.wait(timeout=10)


@pytest.fixture(scope="session")
def rate_limited_server(tmp_path_factory):
    """AI_STUB_FORCE_RATE_LIMIT=1 を設定した別サーバー（429 シナリオ専用）。"""
    port = _free_port()
    db_path = tmp_path_factory.mktemp("db") / "test_rate_limited.db"

    env = os.environ.copy()
    env["DATABASE_URL"] = f"sqlite:///{db_path}"
    env["AI_PROVIDER"] = "stub"
    env["AI_STUB_FORCE_RATE_LIMIT"] = "1"

    process = subprocess.Popen(
        [sys.executable, "-m", "uvicorn", "language_learn.main:app", "--port", str(port)],
        env=env,
        cwd=os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
    )

    base_url = f"http://127.0.0.1:{port}"
    try:
        _wait_until_ready(base_url + "/")
        yield base_url
    finally:
        process.terminate()
        process.wait(timeout=10)
