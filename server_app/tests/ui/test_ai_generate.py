from helpers import unique_word
from playwright.sync_api import Page, expect


def test_ai_generate_fills_form_with_stub_data(page: Page, live_server: str):
    word = unique_word()
    page.goto(live_server + "/words/add")
    page.fill("#word-input", word)
    page.click("#ai-generate-btn")

    expect(page.locator('input[name="reading"]')).to_have_value("/stʌb/")
    expect(page.locator('textarea[name="meaning_0"]')).to_contain_text(word)


def test_ai_generate_button_disabled_during_request_and_cooldown(page: Page, live_server: str):
    word = unique_word()
    page.goto(live_server + "/words/add")
    page.fill("#word-input", word)

    btn = page.locator("#ai-generate-btn")
    btn.click()

    # リクエスト完了直後（クールダウン中）は無効化されている
    expect(btn).to_be_disabled()

    # クールダウン秒数の半分が経過してもまだ無効化されたままである
    # （= リクエスト完了直後に再有効化されてしまう regression を検知する）
    page.wait_for_timeout(7000)
    expect(btn).to_be_disabled()

    # 15 秒のクールダウン後に再度有効化される
    expect(btn).to_be_enabled(timeout=20000)


def test_ai_generate_confirm_popup_when_content_already_generated(page: Page, live_server: str):
    word = unique_word()
    page.goto(live_server + "/words/add")
    page.fill("#word-input", word)
    page.click("#ai-generate-btn")
    expect(page.locator('textarea[name="meaning_0"]')).not_to_have_value("")

    # クールダウンが終わるまで待ってから再度クリックする
    btn = page.locator("#ai-generate-btn")
    expect(btn).to_be_enabled(timeout=20000)

    dialog_messages = []
    page.once("dialog", lambda dialog: (dialog_messages.append(dialog.message), dialog.dismiss()))
    btn.click()
    page.wait_for_timeout(300)

    assert dialog_messages, "再生成の確認ポップアップが表示されなかった"
    assert "再度 AI 生成しますか" in dialog_messages[0]


def test_ai_generate_rate_limit_shows_retry_message(page: Page, rate_limited_server: str):
    word = unique_word()
    page.goto(rate_limited_server + "/words/add")
    page.fill("#word-input", word)
    page.click("#ai-generate-btn")

    error_box = page.locator("#ai-fields")
    expect(error_box).to_contain_text("AI が一時的に利用できません")
    expect(error_box).to_contain_text("秒後に再試行してください")
