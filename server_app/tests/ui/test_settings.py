import re

from playwright.sync_api import Page, expect


def test_settings_page_loads(page: Page, live_server: str):
    page.goto(live_server + "/settings")
    expect(page.get_by_role("heading", name="設定", exact=True)).to_be_visible()
    expect(page.get_by_text("発音設定")).to_be_visible()
    expect(page.get_by_text("インポート / エクスポート")).to_be_visible()


def test_version_displayed_in_nav(page: Page, live_server: str):
    page.goto(live_server + "/")
    expect(page.locator("body")).to_contain_text(re.compile(r"v\d+\.\d+\.\d+"))
