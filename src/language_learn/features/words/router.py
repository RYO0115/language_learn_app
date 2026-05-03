# 単語帳機能のルーター定義
# 単語一覧・追加・詳細・編集・削除のエンドポイントを提供する
from fastapi import APIRouter, Depends, Form, HTTPException, Request
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from sqlalchemy.orm import Session

from language_learn.core.database import get_db
from language_learn.core.exceptions import DuplicateWordError, WordNotFoundError
from language_learn.features.words.schemas import (
    ExampleSentenceCreate,
    SortBy,
    WordCreate,
    WordSourceCreate,
    WordUpdate,
)
from language_learn.features.words.service import (
    create_word,
    delete_word,
    get_word,
    list_words,
    update_word,
)

router = APIRouter()

# テンプレートエンジン（パスは main.py で設定される）
templates: Jinja2Templates | None = None


def set_templates(t: Jinja2Templates) -> None:
    """main.py から templates インスタンスを受け取るためのセッター。"""
    global templates
    templates = t


@router.get("/words", response_class=HTMLResponse)
def word_list_page(
    request: Request,
    sort_by: SortBy = "created_at_desc",
    search: str = "",
    db: Session = Depends(get_db),
):
    """単語一覧ページを返す。ソート・検索クエリパラメータに対応。"""
    words = list_words(db, sort_by=sort_by, search=search)
    return templates.TemplateResponse(
        request,
        "words/list.html",
        {"words": words, "sort_by": sort_by, "search": search},
    )


@router.get("/words/add", response_class=HTMLResponse)
def word_add_page(request: Request):
    """単語追加ページを返す。"""
    return templates.TemplateResponse(request, "words/add.html", {})


@router.post("/words", response_class=HTMLResponse)
def word_create(
    request: Request,
    word: str = Form(...),
    reading: str = Form(default=""),
    meaning: str = Form(...),
    part_of_speech: str = Form(default=""),
    sentence_en_1: str = Form(default=""),
    sentence_ja_1: str = Form(default=""),
    sentence_en_2: str = Form(default=""),
    sentence_ja_2: str = Form(default=""),
    source_type: str = Form(default="other"),
    source_title: str = Form(default=""),
    source_url: str = Form(default=""),
    source_page: str = Form(default=""),
    source_detail: str = Form(default=""),
    db: Session = Depends(get_db),
):
    """フォームから単語を登録する。重複時はエラーメッセージ付きでフォームを再表示。"""
    # 例文リストを構築（空文字は除外）
    example_sentences = []
    if sentence_en_1.strip():
        example_sentences.append(
            ExampleSentenceCreate(sentence_en=sentence_en_1, sentence_ja=sentence_ja_1, order=1)
        )
    if sentence_en_2.strip():
        example_sentences.append(
            ExampleSentenceCreate(sentence_en=sentence_en_2, sentence_ja=sentence_ja_2, order=2)
        )

    # 出典情報（1項目でも入力があれば保存）
    source = None
    if any([source_title.strip(), source_url.strip(), source_page.strip(), source_detail.strip()]):
        source = WordSourceCreate(
            source_type=source_type,
            title=source_title or None,
            url=source_url or None,
            page_number=source_page or None,
            detail=source_detail or None,
        )

    word_data = WordCreate(
        word=word,
        reading=reading or None,
        meaning=meaning,
        part_of_speech=part_of_speech or None,
        example_sentences=example_sentences,
        source=source,
    )

    try:
        create_word(db, word_data)
    except DuplicateWordError as e:
        return templates.TemplateResponse(
            request,
            "words/add.html",
            {"error": str(e), "form_data": {
                "word": word, "reading": reading, "meaning": meaning,
                "part_of_speech": part_of_speech,
                "sentence_en_1": sentence_en_1, "sentence_ja_1": sentence_ja_1,
                "sentence_en_2": sentence_en_2, "sentence_ja_2": sentence_ja_2,
            }},
            status_code=409,
        )

    return RedirectResponse(url="/words", status_code=303)


@router.get("/words/{word_id}", response_class=HTMLResponse)
def word_detail_page(request: Request, word_id: int, db: Session = Depends(get_db)):
    """単語詳細ページを返す。"""
    try:
        word = get_word(db, word_id)
    except WordNotFoundError:
        raise HTTPException(status_code=404, detail="単語が見つかりません")

    # 正答率を取得
    from language_learn.features.quiz.models import QuizAnswer
    from sqlalchemy import func

    total = db.query(func.count(QuizAnswer.id)).filter(QuizAnswer.word_id == word_id).scalar() or 0
    correct = (
        db.query(func.count(QuizAnswer.id))
        .filter(QuizAnswer.word_id == word_id, QuizAnswer.is_correct == True)
        .scalar()
        or 0
    )
    accuracy = round(correct / total * 100, 1) if total > 0 else None

    return templates.TemplateResponse(
        request,
        "words/detail.html",
        {"word": word, "accuracy": accuracy, "quiz_count": total},
    )


@router.post("/words/{word_id}/edit", response_class=HTMLResponse)
def word_update(
    request: Request,
    word_id: int,
    reading: str = Form(default=""),
    meaning: str = Form(...),
    part_of_speech: str = Form(default=""),
    sentence_en_1: str = Form(default=""),
    sentence_ja_1: str = Form(default=""),
    sentence_en_2: str = Form(default=""),
    sentence_ja_2: str = Form(default=""),
    source_type: str = Form(default="other"),
    source_title: str = Form(default=""),
    source_url: str = Form(default=""),
    source_page: str = Form(default=""),
    source_detail: str = Form(default=""),
    db: Session = Depends(get_db),
):
    """単語情報を更新する。"""
    example_sentences = []
    if sentence_en_1.strip():
        example_sentences.append(
            ExampleSentenceCreate(sentence_en=sentence_en_1, sentence_ja=sentence_ja_1, order=1)
        )
    if sentence_en_2.strip():
        example_sentences.append(
            ExampleSentenceCreate(sentence_en=sentence_en_2, sentence_ja=sentence_ja_2, order=2)
        )

    source = None
    if any([source_title.strip(), source_url.strip(), source_page.strip(), source_detail.strip()]):
        source = WordSourceCreate(
            source_type=source_type,
            title=source_title or None,
            url=source_url or None,
            page_number=source_page or None,
            detail=source_detail or None,
        )

    update_data = WordUpdate(
        reading=reading or None,
        meaning=meaning,
        part_of_speech=part_of_speech or None,
        example_sentences=example_sentences,
        source=source,
    )

    try:
        update_word(db, word_id, update_data)
    except WordNotFoundError:
        raise HTTPException(status_code=404, detail="単語が見つかりません")

    return RedirectResponse(url=f"/words/{word_id}", status_code=303)


@router.post("/words/{word_id}/delete")
def word_delete(word_id: int, db: Session = Depends(get_db)):
    """単語を削除し、単語一覧にリダイレクトする。"""
    try:
        delete_word(db, word_id)
    except WordNotFoundError:
        raise HTTPException(status_code=404, detail="単語が見つかりません")
    return RedirectResponse(url="/words", status_code=303)
