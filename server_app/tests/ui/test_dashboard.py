from playwright.sync_api import Page, expect


def test_dashboard_loads(page: Page, live_server: str):
    page.goto(live_server + "/")
    expect(page.get_by_role("heading", name="ダッシュボード")).to_be_visible()
    expect(page.get_by_text("登録単語数")).to_be_visible()
    expect(page.get_by_text("連続学習日数")).to_be_visible()
    expect(page.get_by_text("累計学習日数")).to_be_visible()


def test_dashboard_links_to_add_and_quiz(page: Page, live_server: str):
    page.goto(live_server + "/")
    expect(page.get_by_role("link", name="単語を追加する", exact=False)).to_be_visible()
    expect(page.get_by_role("link", name="テストを開始する", exact=False)).to_be_visible()
