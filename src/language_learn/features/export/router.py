# エクスポート/インポート機能のルーター定義
# JSON・CSV の書き出し・読み込みエンドポイントを提供する
import json
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, File, Request, UploadFile
from fastapi.responses import HTMLResponse, Response
from fastapi.templating import Jinja2Templates
from sqlalchemy.orm import Session

from language_learn.core.database import get_db
from language_learn.core.exceptions import ExportImportError
from language_learn.features.export.service import (
    export_csv,
    export_json,
    import_csv,
    import_json,
)

router = APIRouter()

# テンプレートエンジン（main.py から設定される）
templates: Jinja2Templates | None = None


def set_templates(t: Jinja2Templates) -> None:
    """main.py から templates インスタンスを受け取るためのセッター。"""
    global templates
    templates = t


@router.get("/export", response_class=HTMLResponse)
def export_page(request: Request):
    """エクスポート/インポートページを返す。"""
    return templates.TemplateResponse(request, "export/index.html", {})


@router.get("/export/download/json")
def download_json(db: Session = Depends(get_db)):
    """全単語データを JSON ファイルとしてダウンロードする。"""
    data = export_json(db)
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
    filename = f"vocabulary_{timestamp}.json"
    return Response(
        content=json.dumps(data, ensure_ascii=False, indent=2),
        media_type="application/json",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )


@router.get("/export/download/csv")
def download_csv(db: Session = Depends(get_db)):
    """全単語データを CSV ファイルとしてダウンロードする。"""
    csv_content = export_csv(db)
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
    filename = f"vocabulary_{timestamp}.csv"
    return Response(
        content=csv_content.encode("utf-8-sig"),  # Excel で文字化けしないよう BOM 付き
        media_type="text/csv",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )


@router.post("/export/import", response_class=HTMLResponse)
async def import_file(
    request: Request,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    """JSON または CSV ファイルをアップロードしてインポートする。"""
    if not file.filename:
        return templates.TemplateResponse(
            request,
            "export/index.html",
            {"error": "ファイルが選択されていません。"},
            status_code=400,
        )

    content = await file.read()
    filename_lower = file.filename.lower()

    try:
        if filename_lower.endswith(".json"):
            data = json.loads(content.decode("utf-8"))
            result = import_json(db, data)
        elif filename_lower.endswith(".csv"):
            # BOM 付き UTF-8 にも対応
            text = content.decode("utf-8-sig")
            result = import_csv(db, text)
        else:
            return templates.TemplateResponse(
                request,
                "export/index.html",
                {"error": "JSON または CSV ファイルをアップロードしてください。"},
                status_code=400,
            )
    except (ExportImportError, json.JSONDecodeError, UnicodeDecodeError) as e:
        return templates.TemplateResponse(
            request,
            "export/index.html",
            {"error": f"インポートに失敗しました: {e}"},
            status_code=400,
        )

    return templates.TemplateResponse(
        request,
        "export/index.html",
        {"import_result": result},
    )
