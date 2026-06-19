from helpers import add_word_via_ai_stub, unique_word
from playwright.sync_api import Page, expect


def test_quiz_start_answer_and_result(page: Page, live_server: str):
    word = unique_word()
    add_word_via_ai_stub(page, live_server, word)

    page.goto(live_server + "/quiz")
    expect(page.get_by_role("heading", name="単語テスト")).to_be_visible()
    page.click('button:has-text("テストを開始する")')

    # DB はテストセッション全体で共有されるため出題数は他テストの登録単語数に依存する。
    # 結果画面に到達するまで「意味を確認する」→「覚えている」を繰り返す（上限 30 問）。
    for _ in range(30):
        if "/result" in page.url:
            break
        expect(page.locator("h2.text-4xl")).to_be_visible()
        page.click('button:has-text("意味を確認する")')
        page.click('button:has-text("覚えている")')
        page.wait_for_load_state("load")
    else:
        raise AssertionError("結果画面に到達できなかった")

    expect(page.get_by_role("heading", name="テスト結果")).to_be_visible()
    expect(page.locator("text=問中")).to_be_visible()
