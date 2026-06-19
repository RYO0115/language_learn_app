import uuid

from playwright.sync_api import Page, expect


def unique_word() -> str:
    return f"testword-{uuid.uuid4().hex[:8]}"


def add_word_via_ai_stub(page: Page, base_url: str, word: str) -> None:
    """AI 生成（stub）でフォームを埋めてから保存する、UI 経由の単語追加ヘルパー。"""
    page.goto(base_url + "/words/add")
    page.fill("#word-input", word)
    page.click("#ai-generate-btn")
    expect(page.locator('textarea[name="meaning_0"]')).not_to_have_value("")
    page.click('button:has-text("保存する")')
    page.wait_for_url(f"{base_url}/words")
