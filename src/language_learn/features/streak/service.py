# ストリーク機能のビジネスロジック層
# 学習記録の登録・連続日数計算・カレンダー用データ提供を担当する
from datetime import date, timedelta

from sqlalchemy.dialects.sqlite import insert as sqlite_insert
from sqlalchemy.orm import Session

from language_learn.features.streak.models import StudyRecord
from language_learn.features.streak.schemas import StreakInfo, StudyRecordResponse


def record_study(db: Session, study_date: date, quiz_completed: int = 1) -> None:
    """学習記録を保存する。同日に既にレコードがある場合はクイズ回数をインクリメントする。"""
    stmt = (
        sqlite_insert(StudyRecord)
        .values(study_date=study_date, words_studied=0, quiz_completed=quiz_completed)
        .on_conflict_do_update(
            index_elements=["study_date"],
            set_={"quiz_completed": StudyRecord.quiz_completed + quiz_completed},
        )
    )
    db.execute(stmt)
    db.commit()


def record_word_added(db: Session, study_date: date) -> None:
    """単語追加時の学習記録を保存する。同日レコードがあれば words_studied をインクリメント。"""
    stmt = (
        sqlite_insert(StudyRecord)
        .values(study_date=study_date, words_studied=1, quiz_completed=0)
        .on_conflict_do_update(
            index_elements=["study_date"],
            set_={"words_studied": StudyRecord.words_studied + 1},
        )
    )
    db.execute(stmt)
    db.commit()


def get_all_study_records(db: Session) -> list[StudyRecordResponse]:
    """全学習記録を日付昇順で返す。カレンダー表示に使用する。"""
    records = db.query(StudyRecord).order_by(StudyRecord.study_date.asc()).all()
    return [StudyRecordResponse.model_validate(r) for r in records]


def get_streak_info(db: Session) -> StreakInfo:
    """連続学習日数・最長記録・累計学習日数などのサマリーを返す。"""
    today = date.today()
    records = db.query(StudyRecord).order_by(StudyRecord.study_date.desc()).all()

    if not records:
        return StreakInfo(
            current_streak=0, longest_streak=0, total_days=0, today_studied=False
        )

    study_dates = {r.study_date for r in records}
    total_days = len(study_dates)
    today_studied = today in study_dates

    current_streak = _calculate_current_streak(study_dates, today)
    longest_streak = _calculate_longest_streak(study_dates)

    return StreakInfo(
        current_streak=current_streak,
        longest_streak=longest_streak,
        total_days=total_days,
        today_studied=today_studied,
    )


def _calculate_current_streak(study_dates: set[date], today: date) -> int:
    """今日から遡って連続学習日数を計算する。今日または昨日が含まれていなければ 0 を返す。"""
    # 今日か昨日から始まっていなければストリークは 0
    if today not in study_dates and (today - timedelta(days=1)) not in study_dates:
        return 0

    # 今日から遡って連続日数を数える
    streak = 0
    check_date = today if today in study_dates else today - timedelta(days=1)
    while check_date in study_dates:
        streak += 1
        check_date -= timedelta(days=1)

    return streak


def _calculate_longest_streak(study_dates: set[date]) -> int:
    """全期間を通じた最長連続学習日数を計算する。"""
    if not study_dates:
        return 0

    sorted_dates = sorted(study_dates)
    longest = 1
    current = 1

    for i in range(1, len(sorted_dates)):
        if sorted_dates[i] == sorted_dates[i - 1] + timedelta(days=1):
            current += 1
            longest = max(longest, current)
        else:
            current = 1

    return longest


def get_calendar_data(db: Session, year: int, month: int) -> dict[int, bool]:
    """指定年月のカレンダー用データを返す。日→学習済みかどうかのマップ。"""
    from datetime import date as dt
    import calendar

    _, last_day = calendar.monthrange(year, month)
    start = dt(year, month, 1)
    end = dt(year, month, last_day)

    records = (
        db.query(StudyRecord)
        .filter(StudyRecord.study_date >= start, StudyRecord.study_date <= end)
        .all()
    )
    studied_days = {r.study_date.day for r in records}
    return {day: day in studied_days for day in range(1, last_day + 1)}
