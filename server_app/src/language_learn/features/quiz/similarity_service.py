# 類似単語の事前計算ロジック
# 穴埋め3択テストの誤答選択肢候補を、品詞グループ単位で事前にランキング・保存する。
# 出題時に毎回類似度を計算しなくて済むようにし、探索コストを抑える。
from sqlalchemy.orm import Session

from language_learn.features.quiz.models import WordSimilarity
from language_learn.features.words.models import Word

# 1単語あたり事前計算しておく類似単語の上限件数
SIMILARITY_TOP_N = 5


def _common_prefix_length(a: str, b: str) -> int:
    """2つの文字列の共通プレフィックスの長さを返す（大文字小文字を区別しない）。"""
    a, b = a.lower(), b.lower()
    length = 0
    for ca, cb in zip(a, b):
        if ca != cb:
            break
        length += 1
    return length


def _similarity_score(word_a: str, word_b: str) -> float:
    """2つの単語の類似度スコアを返す（値が大きいほど似ている）。

    先頭文字列の共通プレフィックス長を主要因とし、単語長の差が小さいほど
    わずかにスコアを加点する（同程度の長さの単語ほど見分けがつきにくく、
    より良い誤答選択肢になるため）。
    """
    prefix_len = _common_prefix_length(word_a, word_b)
    length_diff = abs(len(word_a) - len(word_b))
    return prefix_len - length_diff * 0.1


def recompute_similarities_for_part_of_speech(db: Session, part_of_speech: str) -> None:
    """指定した品詞を持つ単語グループの類似度を再計算し、word_similarities に保存し直す。

    既存のレコードは削除してから再登録する（delete + insert）。
    """
    words = (
        db.query(Word)
        .filter(Word.part_of_speech == part_of_speech)
        .all()
    )
    word_ids = [w.id for w in words]

    # 既存レコードを削除（対象単語が word_id または similar_word_id に含まれるもの）
    if word_ids:
        db.query(WordSimilarity).filter(WordSimilarity.word_id.in_(word_ids)).delete(
            synchronize_session=False
        )

    if len(words) < 2:
        db.flush()
        return

    for target in words:
        scored = [
            (other.id, _similarity_score(target.word, other.word))
            for other in words
            if other.id != target.id
        ]
        scored.sort(key=lambda pair: pair[1], reverse=True)
        top = scored[:SIMILARITY_TOP_N]

        for rank, (similar_word_id, _score) in enumerate(top, start=1):
            db.add(WordSimilarity(
                word_id=target.id,
                similar_word_id=similar_word_id,
                rank=rank,
            ))

    db.flush()


def recompute_all_similarities(db: Session) -> None:
    """登録されている全品詞について類似度を再計算する（DB マイグレーション・初期投入用）。"""
    part_of_speech_values = [
        row[0]
        for row in db.query(Word.part_of_speech).distinct().all()
        if row[0]
    ]
    for pos in part_of_speech_values:
        recompute_similarities_for_part_of_speech(db, pos)
    db.commit()
