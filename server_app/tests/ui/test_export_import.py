import json

from helpers import unique_word
from playwright.sync_api import Page, expect


def test_export_redirects_to_settings(page: Page, live_server: str):
    page.goto(live_server + "/export")
    expect(page).to_have_url(live_server + "/settings")


def test_download_json_and_csv(page: Page, live_server: str):
    page.goto(live_server + "/settings")
    page.click('summary:has-text("インポート / エクスポート")')

    with page.expect_download() as download_info:
        page.click('a:has-text("JSON")')
    json_download = download_info.value
    assert json_download.suggested_filename.endswith(".json")

    with page.expect_download() as download_info:
        page.click('a:has-text("CSV")')
    csv_download = download_info.value
    assert csv_download.suggested_filename.endswith(".csv")


def test_import_json_adds_word(page: Page, live_server: str, tmp_path):
    word = unique_word()
    import_file = tmp_path / "import.json"
    import_file.write_text(
        json.dumps([{
            "word": word,
            "reading": "/tɛst/",
            "meaning": "インポートテスト用の意味",
            "part_of_speech": "名詞",
            "example_sentences": [],
            "sources": [],
        }], ensure_ascii=False),
        encoding="utf-8",
    )

    page.goto(live_server + "/settings")
    page.click('summary:has-text("インポート / エクスポート")')
    page.set_input_files('input[name="file"]', str(import_file))
    page.click('button:has-text("インポートする")')

    expect(page.locator("body")).to_contain_text("インポート完了")
    page.goto(live_server + "/words")
    expect(page.get_by_role("link", name=word)).to_be_visible()
