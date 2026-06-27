# アプリケーションエントリーポイント
# FastAPI アプリの生成・ルーター登録・テンプレート設定・DB 初期化を行う
from importlib.metadata import version as _pkg_version
from pathlib import Path

from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

from language_learn.config import settings
from language_learn.core.base_model import Base
from language_learn.core.database import engine
from language_learn.features.ai.router import router as ai_router
from language_learn.features.ai.router import set_templates as ai_set_templates
from language_learn.features.export.router import router as export_router
from language_learn.features.export.router import set_templates as export_set_templates
from language_learn.features.quiz.models import (  # noqa: F401
    QuizAnswer,
    QuizSession,
    QuizSessionWord,
    QuizSessionWordChoice,
    WordSimilarity,
)
from language_learn.features.quiz.router import router as quiz_router
from language_learn.features.quiz.router import set_templates as quiz_set_templates
from language_learn.features.settings.router import router as settings_router
from language_learn.features.settings.router import set_templates as settings_set_templates
from language_learn.features.streak.models import StudyRecord  # noqa: F401
from language_learn.features.streak.router import router as streak_router
from language_learn.features.streak.router import set_templates as streak_set_templates

# 全モデルをインポートして SQLAlchemy のメタデータに登録する（create_all より前に必要）
from language_learn.features.words.models import ExampleSentence, Word, WordSource  # noqa: F401
from language_learn.features.words.router import router as words_router
from language_learn.features.words.router import set_templates as words_set_templates

# プロジェクトルートディレクトリ
BASE_DIR = Path(__file__).resolve().parent.parent.parent

# FastAPI アプリインスタンス
app = FastAPI(title=settings.app_name, debug=settings.debug)

# Jinja2 テンプレートエンジン設定
templates = Jinja2Templates(directory=str(BASE_DIR / "templates"))
templates.env.globals["app_version"] = _pkg_version("language-learn-app")

# 各フィーチャーのルーターにテンプレートを注入
words_set_templates(templates)
ai_set_templates(templates)
quiz_set_templates(templates)
streak_set_templates(templates)
export_set_templates(templates)
settings_set_templates(templates)

# 静的ファイル配信
app.mount("/static", StaticFiles(directory=str(BASE_DIR / "static")), name="static")

# ルーター登録
app.include_router(words_router)
app.include_router(ai_router)
app.include_router(quiz_router)
app.include_router(streak_router)
app.include_router(export_router)
app.include_router(settings_router)


@app.on_event("startup")
def startup_event() -> None:
    """アプリ起動時に DB テーブルを作成し、必要なカラムのマイグレーションを実行する。"""
    from sqlalchemy import text
    Base.metadata.create_all(bind=engine)
    # example_sentences.label カラムの追加（既存 DB 向けマイグレーション）
    with engine.connect() as conn:
        try:
            conn.execute(text("ALTER TABLE example_sentences ADD COLUMN label VARCHAR(50)"))
            conn.commit()
        except Exception:
            pass  # 既にカラムが存在する場合はスキップ

    # quiz_session_words.quiz_type / example_sentence_id カラムの追加（既存 DB 向けマイグレーション）
    with engine.connect() as conn:
        try:
            conn.execute(text(
                "ALTER TABLE quiz_session_words ADD COLUMN quiz_type VARCHAR(20) NOT NULL DEFAULT 'meaning'"
            ))
            conn.commit()
        except Exception:
            pass  # 既にカラムが存在する場合はスキップ
    with engine.connect() as conn:
        try:
            conn.execute(text(
                "ALTER TABLE quiz_session_words ADD COLUMN example_sentence_id INTEGER"
            ))
            conn.commit()
        except Exception:
            pass  # 既にカラムが存在する場合はスキップ

    # 旧フォーマットの DB（word_similarities が未投入）を新フォーマットに作り替える。
    # 単語登録済みなのに類似単語候補が1件もない場合にのみ実行する。
    from sqlalchemy.orm import Session as _Session

    from language_learn.features.quiz.models import WordSimilarity as _WordSimilarity
    from language_learn.features.quiz.similarity_service import recompute_all_similarities
    from language_learn.features.words.models import Word as _Word

    db = _Session(bind=engine)
    try:
        has_words = db.query(_Word.id).first() is not None
        has_similarities = db.query(_WordSimilarity.id).first() is not None
        if has_words and not has_similarities:
            recompute_all_similarities(db)
    finally:
        db.close()

    # データマイグレーション（バージョン連動）: アプリのバージョンが上がったときだけ、
    # 既存データを最新の正規化ルールへ揃え直して DB の形式を最新に保つ。
    from language_learn.core.migrations import run_data_migrations
    run_data_migrations(engine, _pkg_version("language-learn-app"))


@app.get("/", response_class=HTMLResponse)
def dashboard(request: Request):
    """ダッシュボードページを返す。単語数・ストリーク情報を表示する。"""
    from sqlalchemy.orm import Session

    from language_learn.core.database import SessionLocal
    from language_learn.features.streak.service import get_streak_info
    from language_learn.features.words.service import get_word_count

    db: Session = SessionLocal()
    try:
        word_count = get_word_count(db)
        streak_info = get_streak_info(db)
    finally:
        db.close()

    return templates.TemplateResponse(
        request,
        "index.html",
        {
            "word_count": word_count,
            "streak_info": streak_info,
        },
    )


def main() -> None:
    """CLI エントリーポイント（uv run start で起動）。"""
    import uvicorn
    uvicorn.run(
        "language_learn.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.debug,
    )


if __name__ == "__main__":
    main()
