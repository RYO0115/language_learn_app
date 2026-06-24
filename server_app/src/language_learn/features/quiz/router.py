# クイズ機能のルーター定義
# テスト開始・問題表示・回答送信・結果表示のエンドポイントを提供する
from fastapi import APIRouter, Depends, Form, HTTPException, Request
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from sqlalchemy.orm import Session

from language_learn.core.database import get_db
from language_learn.core.exceptions import QuizSessionError
from language_learn.features.quiz.service import (
    get_fill_blank_question_data,
    get_next_question,
    get_quiz_result,
    is_fill_blank_unlocked,
    start_quiz,
    submit_answer,
    submit_fill_blank_answer,
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
        {
            "word_count": word_count,
            "phase": "start",
            "fill_blank_unlocked": is_fill_blank_unlocked(db),
        },
    )


@router.post("/quiz/start", response_class=HTMLResponse)
def quiz_start(
    request: Request,
    quiz_type: str = Form(default="meaning"),
    db: Session = Depends(get_db),
):
    """クイズセッションを開始し、最初の問題 HTML を返す。

    quiz_type: "meaning"（意味確認テスト）または "fill_blank"（例文穴埋め3択テスト）
    """
    try:
        session = start_quiz(db, quiz_type=quiz_type)
    except QuizSessionError as e:
        return templates.TemplateResponse(
            request,
            "quiz/session.html",
            {
                "error": str(e),
                "phase": "start",
                "word_count": get_word_count(db),
                "fill_blank_unlocked": is_fill_blank_unlocked(db),
            },
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

    if next_q.quiz_type == "fill_blank":
        data = get_fill_blank_question_data(db, next_q)
        return templates.TemplateResponse(
            request,
            "quiz/session.html",
            {
                "phase": "fill_blank_question",
                "session_id": session_id,
                "session_word_id": next_q.id,
                "word": data["word"],
                "sentence_en_blanked": data["sentence_en_blanked"],
                "choices": data["choices"],
                "current_num": current_num,
                "total": total,
            },
        )

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
    quiz_type: str = Form(default="meaning"),
    word_id: int | None = Form(default=None),
    is_correct: bool | None = Form(default=None),
    session_word_id: int | None = Form(default=None),
    selected_word_id: int | None = Form(default=None),
    db: Session = Depends(get_db),
):
    """回答を送信する。

    quiz_type == "fill_blank" の場合はフィードバック画面（例文訳・選択肢の意味・正誤）を
    その場で返す。それ以外（意味確認テスト）は次の問題 or 結果画面へリダイレクトする。
    """
    if quiz_type == "fill_blank":
        feedback = submit_fill_blank_answer(db, session_id, session_word_id, selected_word_id)
        return templates.TemplateResponse(
            request,
            "quiz/session.html",
            {
                "phase": "fill_blank_feedback",
                "session_id": session_id,
                "is_completed": feedback["is_completed"],
                "is_correct": feedback["is_correct"],
                "sentence_en": feedback["sentence_en"],
                "sentence_ja": feedback["sentence_ja"],
                "choices": feedback["choices"],
            },
        )

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
