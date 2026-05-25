# ストリーク機能のルーター定義
# 実績・連続学習カレンダーページを提供する
from datetime import date

from fastapi import APIRouter, Depends, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from sqlalchemy.orm import Session

from language_learn.core.database import get_db
from language_learn.features.streak.service import (
    get_calendar_data,
    get_streak_info,
)

router = APIRouter()

# テンプレートエンジン（main.py から設定される）
templates: Jinja2Templates | None = None


def set_templates(t: Jinja2Templates) -> None:
    """main.py から templates インスタンスを受け取るためのセッター。"""
    global templates
    templates = t


@router.get("/streak", response_class=HTMLResponse)
def streak_page(
    request: Request,
    year: int = 0,
    month: int = 0,
    db: Session = Depends(get_db),
):
    """実績ページを表示する。年・月をクエリパラメータで指定可能（デフォルトは今月）。"""
    today = date.today()
    if not year:
        year = today.year
    if not month:
        month = today.month

    streak_info = get_streak_info(db)
    calendar_data = get_calendar_data(db, year, month)

    # 前月・翌月のナビゲーション用
    prev_month = month - 1 if month > 1 else 12
    prev_year = year if month > 1 else year - 1
    next_month = month + 1 if month < 12 else 1
    next_year = year if month < 12 else year + 1

    return templates.TemplateResponse(
        request,
        "streak/calendar.html",
        {
            "streak_info": streak_info,
            "calendar_data": calendar_data,
            "year": year,
            "month": month,
            "prev_year": prev_year,
            "prev_month": prev_month,
            "next_year": next_year,
            "next_month": next_month,
            "today": today,
        },
    )
