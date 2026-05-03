# Language Learn App — 単語帳アプリ

日本語話者向けの英語学習単語帳 Web アプリです。

## 機能

- **単語登録**: 英単語を入力し、Claude AI で意味・発音・品詞・例文（2種類）を自動生成
- **単語帳**: 一覧表示・ソート（登録日・アルファベット・正答率）・検索・出典情報管理
- **単語テスト**: 未テスト・低正答率の単語を優先した 20 問テスト（覚えている/覚えていない）
- **実績**: 連続学習日数・最長ストリーク・カレンダー表示
- **エクスポート/インポート**: JSON・CSV 形式での書き出し・読み込み

## セットアップ

### 必要条件

- Python 3.12+
- [uv](https://docs.astral.sh/uv/) パッケージマネージャー
- Anthropic API キー

### インストール

```bash
# 依存関係をインストール
uv sync

# 環境変数を設定
cp .env.example .env
# .env を編集して ANTHROPIC_API_KEY を設定
```

### 起動

```bash
uv run uvicorn language_learn.main:app --reload
```

ブラウザで [http://localhost:8000](http://localhost:8000) を開いてください。

## ディレクトリ構成

```
language_learn_app/
├── src/language_learn/
│   ├── main.py             # FastAPI アプリ起動エントリーポイント
│   ├── config.py           # アプリ設定
│   ├── core/               # 共通基盤（DB・ベースモデル・例外）
│   └── features/           # 機能別モジュール
│       ├── words/          # 単語帳機能
│       ├── ai/             # AI（Claude API）連携
│       ├── quiz/           # テスト機能
│       ├── streak/         # 実績・ストリーク機能
│       └── export/         # エクスポート/インポート
├── templates/              # Jinja2 HTML テンプレート
├── static/                 # CSS・JS 静的ファイル
└── data/                   # SQLite データベースファイル
```

## 技術スタック

| 項目 | 技術 |
|------|------|
| バックエンド | FastAPI + Jinja2 |
| フロントエンド | HTMX + Alpine.js + Tailwind CSS |
| データベース | SQLite + SQLAlchemy 2.x |
| AI | Anthropic Claude API |
| パッケージ管理 | uv |
