# エクスポート/インポート機能のビジネスロジック層
# JSON・CSV 形式でのデータ書き出し・読み込みを担当する
import csv
import io
import json
from datetime import datetime, timezone

from sqlalchemy.orm import Session

from language_learn.core.exceptions import ExportImportError
from language_learn.features.export.schemas import ImportResult
from language_learn.features.words.models import ExampleSentence, Word, WordSource
from language_learn.features.words.service import get_word_by_text


# ---- JSON エクスポート ----

def export_json(db: Session) -> list:
    """全単語データを JSON エクスポート用のリスト形式で返す。スマートフォンアプリと互換のフォーマット。"""
    words = db.query(Word).order_by(Word.created_at.asc()).all()
    result = []
    for word in words:
        result.append({
            "word": word.word,
            "reading": word.reading,
            "meaning": word.meaning,
            "part_of_speech": word.part_of_speech,
            "example_sentences": [
                {
                    "sentence_en": s.sentence_en,
                    "sentence_ja": s.sentence_ja,
                    "order": s.order,
                    "label": s.label,
                }
                for s in word.example_sentences
            ],
            "sources": [
                {
                    "source_type": src.source_type,
                    "title": src.title,
                    "url": src.url,
                    "page_number": src.page_number,
                    "detail": src.detail,
                }
                for src in word.sources
            ],
        })
    return result


# ---- JSON インポート ----

def import_json(db: Session, data: dict | list) -> ImportResult:
    """JSON 形式のデータをインポートする。重複単語はスキップして件数を報告する。
    配列形式 ([{...}]) とオブジェクト形式 ({"words": [...]}) の両方を受け付ける。
    """
    if isinstance(data, list):
        words_data = data
    else:
        words_data = data.get("words", [])
    if not isinstance(words_data, list):
        raise ExportImportError("JSON フォーマットが正しくありません。配列か 'words' キーが必要です。")

    result = ImportResult()
    now = datetime.now(timezone.utc)

    for item in words_data:
        word_text = item.get("word", "").strip()
        if not word_text:
            result.error_count += 1
            result.errors.append("空の単語エントリをスキップしました。")
            continue

        # 重複チェック
        if get_word_by_text(db, word_text):
            result.skipped_count += 1
            continue

        try:
            word = Word(
                word=word_text,
                reading=item.get("reading"),
                meaning=item.get("meaning", ""),
                part_of_speech=item.get("part_of_speech"),
            )
            db.add(word)
            db.flush()

            for sent in item.get("example_sentences", []):
                db.add(ExampleSentence(
                    word_id=word.id,
                    sentence_en=sent.get("sentence_en", ""),
                    sentence_ja=sent.get("sentence_ja", ""),
                    order=sent.get("order", 1),
                    label=sent.get("label"),
                ))

            for src in item.get("sources", []):
                db.add(WordSource(
                    word_id=word.id,
                    source_type=src.get("source_type", "other"),
                    title=src.get("title"),
                    url=src.get("url"),
                    page_number=src.get("page_number"),
                    detail=src.get("detail"),
                    created_at=now,
                ))

            result.imported_count += 1

        except Exception as e:
            db.rollback()
            result.error_count += 1
            result.errors.append(f"「{word_text}」の登録に失敗: {e}")
            continue

    db.commit()
    return result


# ---- CSV エクスポート ----

# CSV のカラム定義（将来の拡張を想定してここで管理する）
CSV_COLUMNS = [
    "word", "reading", "meaning", "part_of_speech",
    "example_en_1", "example_ja_1", "example_en_2", "example_ja_2",
    "source_type", "source_title", "source_url", "source_page", "source_detail",
]


def export_csv(db: Session) -> str:
    """全単語データを CSV 文字列としてエクスポートする。"""
    words = db.query(Word).order_by(Word.created_at.asc()).all()
    output = io.StringIO()
    writer = csv.DictWriter(output, fieldnames=CSV_COLUMNS)
    writer.writeheader()

    for word in words:
        # 例文（最大2件）
        sents = sorted(word.example_sentences, key=lambda s: s.order)
        ex1 = sents[0] if len(sents) > 0 else None
        ex2 = sents[1] if len(sents) > 1 else None

        # 出典（最初の1件）
        src = word.sources[0] if word.sources else None

        writer.writerow({
            "word": word.word,
            "reading": word.reading or "",
            "meaning": word.meaning,
            "part_of_speech": word.part_of_speech or "",
            "example_en_1": ex1.sentence_en if ex1 else "",
            "example_ja_1": ex1.sentence_ja if ex1 else "",
            "example_en_2": ex2.sentence_en if ex2 else "",
            "example_ja_2": ex2.sentence_ja if ex2 else "",
            "source_type": src.source_type if src else "",
            "source_title": src.title or "" if src else "",
            "source_url": src.url or "" if src else "",
            "source_page": src.page_number or "" if src else "",
            "source_detail": src.detail or "" if src else "",
        })

    return output.getvalue()


# ---- CSV インポート ----

def import_csv(db: Session, csv_content: str) -> ImportResult:
    """CSV 文字列からデータをインポートする。重複単語はスキップして件数を報告する。"""
    result = ImportResult()
    now = datetime.now(timezone.utc)

    try:
        reader = csv.DictReader(io.StringIO(csv_content))
    except Exception as e:
        raise ExportImportError(f"CSV の解析に失敗しました: {e}") from e

    for row in reader:
        word_text = row.get("word", "").strip()
        if not word_text:
            continue

        # 重複チェック
        if get_word_by_text(db, word_text):
            result.skipped_count += 1
            continue

        try:
            word = Word(
                word=word_text,
                reading=row.get("reading") or None,
                meaning=row.get("meaning", ""),
                part_of_speech=row.get("part_of_speech") or None,
            )
            db.add(word)
            db.flush()

            # 例文1
            if row.get("example_en_1", "").strip():
                db.add(ExampleSentence(
                    word_id=word.id,
                    sentence_en=row["example_en_1"],
                    sentence_ja=row.get("example_ja_1", ""),
                    order=1,
                ))
            # 例文2
            if row.get("example_en_2", "").strip():
                db.add(ExampleSentence(
                    word_id=word.id,
                    sentence_en=row["example_en_2"],
                    sentence_ja=row.get("example_ja_2", ""),
                    order=2,
                ))

            # 出典情報
            if any(row.get(k, "").strip() for k in ["source_title", "source_url", "source_page", "source_detail"]):
                db.add(WordSource(
                    word_id=word.id,
                    source_type=row.get("source_type", "other") or "other",
                    title=row.get("source_title") or None,
                    url=row.get("source_url") or None,
                    page_number=row.get("source_page") or None,
                    detail=row.get("source_detail") or None,
                    created_at=now,
                ))

            result.imported_count += 1

        except Exception as e:
            db.rollback()
            result.error_count += 1
            result.errors.append(f"「{word_text}」の登録に失敗: {e}")
            continue

    db.commit()
    return result
