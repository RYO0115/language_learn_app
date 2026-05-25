# Language Learn App — 開発ガイド

## リポジトリ構成

```
language_learn_app/
├── docs/              ← 設計ドキュメント
├── server_app/        ← Python (FastAPI) アプリ
└── smartphone_app/    ← Flutter アプリ
```

## バージョン管理ルール

バージョンは `server_app/pyproject.toml` の `version` フィールドで一元管理する。
変更後は必ず `server_app/` ディレクトリ内で以下のコマンドでバージョンをインクリメントすること。
コマンドは `pyproject.toml` の更新・git commit・git tag を自動で行う。

| 変更の種類 | コマンド | 例 |
|-----------|----------|----|
| 大規模実装（アーキテクチャ変更・破壊的変更） | `cd server_app && uv run bump-my-version bump major` | 0.1.0 → 1.0.0 |
| 機能追加 | `cd server_app && uv run bump-my-version bump minor` | 0.1.0 → 0.2.0 |
| 細かい修正・バグ修正・UI 調整など | `cd server_app && uv run bump-my-version bump patch` | 0.1.0 → 0.1.1 |

> minor をインクリメントすると patch はリセット、major をインクリメントすると minor・patch はリセットされる。
