from playwright.sync_api import Page, expect


def test_streak_calendar_loads(page: Page, live_server: str):
    page.goto(live_server + "/streak")
    expect(page.get_by_role("heading", name="実績")).to_be_visible()
    expect(page.get_by_text("現在の連続日数")).to_be_visible()
    expect(page.get_by_text("最長連続日数")).to_be_visible()
    expect(page.get_by_text("累計学習日数")).to_be_visible()
    expect(page.locator(".calendar-grid")).to_be_visible()
