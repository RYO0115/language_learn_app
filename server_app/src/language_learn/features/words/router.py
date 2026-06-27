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
    bulk_delete_words,
    create_word,
    delete_word,
    get_source_suggestions,
    get_word,
    list_words,
    normalize_word_text,
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
    """単語一覧ページを返す。ソート・検索クエリパラメータに対応。
    検索語が入力されて結果が0件の場合は新規追加画面へリダイレクトする。
    """
    # 検索語を正規化（末尾の空白・ゼロ幅文字で検索ミス／意図しないリダイレクトが起きるのを防ぐ）
    search = normalize_word_text(search)
    words = list_words(db, sort_by=sort_by, search=search)
    if search and not words:
        from urllib.parse import quote
        return RedirectResponse(url=f"/words/add?word={quote(search)}", status_code=303)
    return templates.TemplateResponse(
        request,
        "words/list.html",
        {"words": words, "sort_by": sort_by, "search": search},
    )


@router.get("/words/add", response_class=HTMLResponse)
def word_add_page(request: Request, word: str = "", db: Session = Depends(get_db)):
    """単語追加ページを返す。出典情報の入力補完用に過去の候補も渡す。
    word クエリパラメータが渡された場合は入力欄の初期値として使用する。
    """
    return templates.TemplateResponse(
        request, "words/add.html",
        {"source_suggestions": get_source_suggestions(db), "initial_word": word},
    )


@router.post("/words", response_class=HTMLResponse)
async def word_create(request: Request, db: Session = Depends(get_db)):
    """フォームから単語を登録する。品詞ごとにインデックスされたフィールドを解析する。

    フォームフィールド形式:
      word, reading
      meaning_0, part_of_speech_0, sentence_en_0_0, sentence_ja_0_0, sentence_en_0_1, ...
      meaning_1, part_of_speech_1, sentence_en_1_0, ...  （複数品詞の場合）
      source_type, source_title, source_url, source_page, source_detail
    """
    form = await request.form()
    word_text = normalize_word_text(str(form.get("word", "")))
    reading = str(form.get("reading", "")).strip()

    # 品詞ごとの意味・例文を収集（最大 8 品詞まで対応）
    example_sentences: list[ExampleSentenceCreate] = []
    meaning_parts: list[str] = []
    pos_parts: list[str] = []
    order_counter = 1

    for i in range(8):
        meaning_i = str(form.get(f"meaning_{i}", "")).strip()
        if not meaning_i:
            break
        pos_i = str(form.get(f"part_of_speech_{i}", "")).strip()
        # 意味テキストは「【品詞】意味」形式で結合
        meaning_parts.append(f"【{pos_i}】{meaning_i}" if pos_i else meaning_i)
        pos_parts.append(pos_i)

        for j in range(4):  # 1品詞につき最大 4 例文
            en = str(form.get(f"sentence_en_{i}_{j}", "")).strip()
            ja = str(form.get(f"sentence_ja_{i}_{j}", "")).strip()
            if not en:
                break
            example_sentences.append(ExampleSentenceCreate(
                sentence_en=en,
                sentence_ja=ja,
                order=order_counter,
                label=pos_i or None,
            ))
            order_counter += 1

    combined_meaning = "\n\n".join(meaning_parts)
    combined_pos = "・".join(p for p in pos_parts if p) or None

    # 出典情報（1項目でも入力があれば保存）
    source_type = str(form.get("source_type", "other"))
    source_title = str(form.get("source_title", "")).strip()
    source_url = str(form.get("source_url", "")).strip()
    source_page = str(form.get("source_page", "")).strip()
    source_detail = str(form.get("source_detail", "")).strip()
    source = None
    if any([source_title, source_url, source_page, source_detail]):
        source = WordSourceCreate(
            source_type=source_type,
            title=source_title or None,
            url=source_url or None,
            page_number=source_page or None,
            detail=source_detail or None,
        )

    word_data = WordCreate(
        word=word_text,
        reading=reading or None,
        meaning=combined_meaning,
        part_of_speech=combined_pos,
        example_sentences=example_sentences,
        source=source,
    )

    try:
        create_word(db, word_data)
    except DuplicateWordError as e:
        return templates.TemplateResponse(
            request,
            "words/add.html",
            {"error": str(e)},
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
    from sqlalchemy import func

    from language_learn.features.quiz.models import QuizAnswer

    total = db.query(func.count(QuizAnswer.id)).filter(QuizAnswer.word_id == word_id).scalar() or 0
    correct = (
        db.query(func.count(QuizAnswer.id))
        .filter(QuizAnswer.word_id == word_id, QuizAnswer.is_correct.is_(True))
        .scalar()
        or 0
    )
    accuracy = round(correct / total * 100, 1) if total > 0 else None

    return templates.TemplateResponse(
        request,
        "words/detail.html",
        {
            "word": word,
            "accuracy": accuracy,
            "quiz_count": total,
            "source_suggestions": get_source_suggestions(db),
        },
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


@router.post("/words/bulk-delete")
def words_bulk_delete(
    request: Request,
    word_ids: list[int] = Form(default=[]),
    db: Session = Depends(get_db),
):
    """選択された複数の単語を一括削除し、単語一覧にリダイレクトする。"""
    if word_ids:
        bulk_delete_words(db, word_ids)
    return RedirectResponse(url="/words", status_code=303)


@router.post("/words/{word_id}/delete")
def word_delete(word_id: int, db: Session = Depends(get_db)):
    """単語を削除し、単語一覧にリダイレクトする。"""
    try:
        delete_word(db, word_id)
    except WordNotFoundError:
        raise HTTPException(status_code=404, detail="単語が見つかりません")
    return RedirectResponse(url="/words", status_code=303)
