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

## server_app 開発ワークフロー

### 実装前に必ず確認するドキュメント

`server_app` に関わる機能追加・修正を依頼された場合、**実装前に必ず以下の3ファイルを読み込んで現状を把握**すること。

| ファイル | 内容 |
|---------|------|
| `docs/server_app/機能一覧.md` | 現在実装済みの機能一覧 |
| `docs/server_app/設計書.md` | アーキテクチャ・DB スキーマ・設定値 |
| `docs/server_app/仕様書.md` | 全 API エンドポイントの詳細仕様 |

これらのドキュメントを確認したうえで、既存機能との整合性を考慮しながら実装方針を検討すること。

### 実装完了後に必ず行う更新

機能追加・変更・削除が完了したら、**実装内容に合わせて上記3ファイルを更新**すること。

- **新機能追加**: `機能一覧.md` に機能を追記、`仕様書.md` に API 仕様を追記、`設計書.md` の DB スキーマや設定を更新
- **機能変更**: 変更した機能・API・スキーマの記述を修正
- **機能削除**: 該当エントリを削除
- **各ファイル冒頭の「最終更新」日付とバージョンも更新**すること
