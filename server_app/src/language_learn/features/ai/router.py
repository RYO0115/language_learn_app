# AI 連携機能のルーター定義
# HTMX から呼び出され、AI 生成結果を HTML パーシャルで返す
from fastapi import APIRouter, Depends, Form, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from spellchecker import SpellChecker
from sqlalchemy.orm import Session

from language_learn.core.database import get_db
from language_learn.core.exceptions import AIRateLimitError, AIServiceError
from language_learn.features.ai.service import generate_word_info
from language_learn.features.words.service import get_word_by_text

_spell = SpellChecker()

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
    except AIRateLimitError as e:
        return templates.TemplateResponse(
            request,
            "words/partials/ai_error.html",
            {"error": str(e), "retry_after_seconds": e.retry_after_seconds},
            status_code=429,
        )
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


@router.post("/api/spell-check", response_class=HTMLResponse)
def spell_check(request: Request, word: str = Form(...), db: Session = Depends(get_db)):
    """英単語のスペルチェックと重複チェックを行い、結果を HTML パーシャルで返す。

    登録済み単語の場合は重複メッセージを返す。
    辞書に存在するか候補がない場合は空レスポンスを返す。
    """
    word = word.strip()
    if not word:
        return HTMLResponse("")
    existing = get_word_by_text(db, word)
    if existing:
        return templates.TemplateResponse(
            request,
            "words/partials/duplicate_word.html",
            {"word": existing},
        )
    if _spell.known([word]):
        return HTMLResponse("")
    candidates = _spell.candidates(word) or set()
    suggestions = sorted(candidates - {word.lower()})[:3]
    if not suggestions:
        return HTMLResponse("")
    return templates.TemplateResponse(
        request,
        "words/partials/spell_suggestions.html",
        {"suggestions": suggestions},
    )
