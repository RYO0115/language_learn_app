from playwright.sync_api import Page, expect

from helpers import add_word_via_ai_stub, unique_word


def test_add_word_page_loads(page: Page, live_server: str):
    page.goto(live_server + "/words/add")
    expect(page.get_by_role("heading", name="単語を追加")).to_be_visible()
    expect(page.locator("#word-input")).to_be_visible()
    expect(page.locator("#ai-generate-btn")).to_be_visible()


def test_add_word_via_ai_stub_appears_in_list(page: Page, live_server: str):
    word = unique_word()
    add_word_via_ai_stub(page, live_server, word)

    page.goto(live_server + "/words")
    expect(page.get_by_role("link", name=word)).to_be_visible()


def test_duplicate_word_detection(page: Page, live_server: str):
    word = unique_word()
    add_word_via_ai_stub(page, live_server, word)

    page.goto(live_server + "/words/add")
    page.fill("#word-input", word)
    page.locator("#word-input").blur()
    expect(page.locator("#spell-suggestions")).to_contain_text("すでに登録されています")


def test_word_detail_edit_and_delete(page: Page, live_server: str):
    word = unique_word()
    add_word_via_ai_stub(page, live_server, word)

    page.goto(live_server + "/words")
    page.get_by_role("link", name=word).click()
    expect(page.get_by_role("heading", name=word)).to_be_visible()

    # 編集
    page.click('button:has-text("編集")')
    new_meaning = f"更新後の意味-{unique_word()}"
    page.fill('textarea[name="meaning"]', new_meaning)
    page.click('button:has-text("更新する")')
    expect(page.locator("p.text-gray-800.leading-relaxed")).to_have_text(new_meaning)

    # 削除（確認ポップアップを許諾）
    page.once("dialog", lambda dialog: dialog.accept())
    page.click('button:has-text("削除")')
    page.wait_for_url(f"{live_server}/words")
    expect(page.get_by_role("link", name=word)).not_to_be_visible()
