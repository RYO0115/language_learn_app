from helpers import add_word_via_ai_stub, unique_word
from playwright.sync_api import Page, expect


def test_fill_blank_quiz_unlocks_and_completes(page: Page, live_server: str):
    # stub AI 生成は常に品詞「名詞」・本文中に単語そのものを含む例文を返すため、
    # 3件登録すれば穴埋め3択テストがアンロックされる
    for _ in range(3):
        add_word_via_ai_stub(page, live_server, unique_word())

    page.goto(live_server + "/quiz")
    expect(page.get_by_role("button", name="穴埋め3択テストを開始する", exact=False)).to_be_visible()
    page.click('button:has-text("穴埋め3択テストを開始する")')

    page.wait_for_url(lambda url: "/quiz/" in url and "/result" not in url)

    for _ in range(10):
        if "/result" in page.url:
            break

        expect(page.locator("text=空欄に入る単語は？")).to_be_visible()
        choice_buttons = page.locator('form[action^="/quiz/"] button[type="submit"]')
        expect(choice_buttons.first).to_be_visible()
        choice_buttons.first.click()

        expect(page.locator("text=選択肢の意味")).to_be_visible()
        expect(page.locator("text=例文の訳")).to_be_visible()

        next_link = page.get_by_role("link", name="次へ")
        result_link = page.get_by_role("link", name="結果を見る")
        if result_link.count() > 0:
            result_link.click()
        else:
            next_link.click()
    else:
        raise AssertionError("結果画面に到達できなかった")

    expect(page.get_by_role("heading", name="テスト結果")).to_be_visible()
