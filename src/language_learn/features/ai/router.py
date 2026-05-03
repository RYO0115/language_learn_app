# AI 連携機能のルーター定義
# HTMX から呼び出され、AI 生成結果を HTML パーシャルで返す
from fastapi import APIRouter, Form, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates

from language_learn.core.exceptions import AIServiceError
from language_learn.features.ai.service import generate_word_info

router = APIRouter()

# テンプレートエンジン（main.py から設定される）
templates: Jinja2Templates | None = None


def set_templates(t: Jinja2Templates) -> None:
    """main.py から templates インスタンスを受け取るためのセッター。"""
    global templates
    templates = t


@router.post("/api/ai/generate", response_class=HTMLResponse)
def ai_generate(request: Request, word: str = Form(...)):
    """英単語の情報を AI で生成し、フォーム入力用の HTML パーシャルを返す。

    HTMX の hx-target に対してフォームフィールドを含む HTML を返す。
    """
    try:
        result = generate_word_info(word)
    except AIServiceError as e:
        return templates.TemplateResponse(
            request,
            "words/partials/ai_error.html",
            {"error": str(e)},
            status_code=500,
        )

    return templates.TemplateResponse(
        request,
        "words/partials/ai_result.html",
        {"result": result, "word": word},
    )
