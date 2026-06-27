# データマイグレーション（バージョン連動）
# アプリのバージョンが上がったときに、DB 上の既存データを最新の形式へ揃えるための処理。
#
# スキーマ（カラム追加）のマイグレーションは main.py 起動時に毎回冪等に実行しているが、
# こちらは「データ内容」を最新ルールへ正規化する処理で、毎回走らせる必要はないため、
# app_meta テーブルに最後に適用したバージョンを記録し、バージョンが変わったときだけ実行する。
from sqlalchemy import text
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session

# データマイグレーションの適用済みバージョンを保存するメタ情報のキー
_DATA_VERSION_KEY = "data_version"


def _ensure_meta_table(engine: Engine) -> None:
    """key-value 形式のメタ情報テーブル（app_meta）が無ければ作成する。"""
    with engine.connect() as conn:
        conn.execute(text(
            "CREATE TABLE IF NOT EXISTS app_meta (key TEXT PRIMARY KEY, value TEXT)"
        ))
        conn.commit()


def get_data_version(engine: Engine) -> str | None:
    """最後にデータマイグレーションを適用したバージョンを返す（未記録なら None）。"""
    _ensure_meta_table(engine)
    with engine.connect() as conn:
        row = conn.execute(
            text("SELECT value FROM app_meta WHERE key = :k"),
            {"k": _DATA_VERSION_KEY},
        ).first()
    return row[0] if row else None


def set_data_version(engine: Engine, version: str) -> None:
    """データマイグレーション適用済みバージョンを記録（UPSERT）する。"""
    _ensure_meta_table(engine)
    with engine.connect() as conn:
        conn.execute(
            text(
                "INSERT INTO app_meta (key, value) VALUES (:k, :v) "
                "ON CONFLICT(key) DO UPDATE SET value = :v"
            ),
            {"k": _DATA_VERSION_KEY, "v": version},
        )
        conn.commit()


def run_data_migrations(engine: Engine, current_version: str) -> bool:
    """記録済みバージョンと現在のバージョンが異なる場合のみデータマイグレーションを実行する。

    バージョンが上がるたびに既存データを最新ルールへ揃え直し、DB の形式を最新に保つ。
    現状の処理:
      - 全単語テキストの正規化（過去にゼロ幅文字・余分な空白付きで登録された単語の修復）と
        正規化で生じた重複のマージ。

    Returns:
        実際にマイグレーションを実行した場合は True、スキップした場合は False。
    """
    # 遅延インポートで循環参照を回避
    from language_learn.features.words.service import normalize_existing_words

    if get_data_version(engine) == current_version:
        return False

    db = Session(bind=engine)
    try:
        normalize_existing_words(db)
        # 今後のデータマイグレーションはここに追記する
    finally:
        db.close()

    set_data_version(engine, current_version)
    return True
