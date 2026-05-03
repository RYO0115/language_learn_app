# クイズ機能のルーター定義
# テスト開始・問題表示・回答送信・結果表示のエンドポイントを提供する
from fastapi import APIRouter, Depends, Form, HTTPException, Request
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from sqlalchemy.orm import Session

from language_learn.core.database import get_db
from language_learn.core.exceptions import QuizSessionError
from language_learn.features.quiz.service import (
    get_next_question,
    get_quiz_result,
    start_quiz,
    submit_answer,
)
from language_learn.features.words.service import get_word_count

router = APIRouter()

# テンプレートエンジン（main.py から設定される）
templates: Jinja2Templates | None = None


def set_templates(t: Jinja2Templates) -> None:
    """main.py から templates インスタンスを受け取るためのセッター。"""
    global templates
    templates = t


@router.get("/quiz", response_class=HTMLResponse)
def quiz_top_page(request: Request, db: Session = Depends(get_db)):
    """クイズトップページ。単語数が不足している場合は警告を表示する。"""
    word_count = get_word_count(db)
    return templates.TemplateResponse(
        request,
        "quiz/session.html",
        {"word_count": word_count, "phase": "start"},
    )


@router.post("/quiz/start", response_class=HTMLResponse)
def quiz_start(request: Request, db: Session = Depends(get_db)):
    """クイズセッションを開始し、最初の問題 HTML を返す。"""
    try:
        session = start_quiz(db)
    except QuizSessionError as e:
        return templates.TemplateResponse(
            request,
            "quiz/session.html",
            {"error": str(e), "phase": "start", "word_count": 0},
        )

    # セッション開始後、最初の問題にリダイレクト
    return RedirectResponse(url=f"/quiz/{session.id}", status_code=303)


@router.get("/quiz/{session_id}", response_class=HTMLResponse)
def quiz_question_page(request: Request, session_id: int, db: Session = Depends(get_db)):
    """現在の問題ページを表示する。全問終了していれば結果ページにリダイレクト。"""
    next_q, current_num, total = get_next_question(db, session_id)

    if next_q is None:
        # 全問回答済み → 結果ページへ
        return RedirectResponse(url=f"/quiz/{session_id}/result", status_code=303)

    word = next_q.word
    return templates.TemplateResponse(
        request,
        "quiz/session.html",
        {
            "phase": "question",
            "session_id": session_id,
            "word": word,
            "current_num": current_num,
            "total": total,
        },
    )


@router.post("/quiz/{session_id}/answer", response_class=HTMLResponse)
def quiz_answer(
    request: Request,
    session_id: int,
    word_id: int = Form(...),
    is_correct: bool = Form(...),
    db: Session = Depends(get_db),
):
    """回答を送信し、次の問題にリダイレクトする。"""
    is_completed = submit_answer(db, session_id, word_id, is_correct)

    if is_completed:
        return RedirectResponse(url=f"/quiz/{session_id}/result", status_code=303)
    return RedirectResponse(url=f"/quiz/{session_id}", status_code=303)


@router.get("/quiz/{session_id}/result", response_class=HTMLResponse)
def quiz_result_page(request: Request, session_id: int, db: Session = Depends(get_db)):
    """クイズ結果ページを表示する。"""
    try:
        result = get_quiz_result(db, session_id)
    except Exception:
        raise HTTPException(status_code=404, detail="クイズセッションが見つかりません")

    return templates.TemplateResponse(
        request,
        "quiz/session.html",
        {"phase": "result", "result": result},
    )
