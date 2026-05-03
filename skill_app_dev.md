# Language Learn App 開発ルール・指示書

## プロジェクト概要
外国語学習単語帳アプリ。まずは日本語話者向け英語学習機能を実装。

---

## 技術スタック
- Python 3.12+ / uv
- FastAPI + Jinja2 + HTMX + Alpine.js + Tailwind CSS (CDN)
- SQLAlchemy 2.x + SQLite
- AI: Anthropic Claude API / Google Gemini API（.env の AI_PROVIDER で切り替え）

---

## 機能要件

### 単語登録
- 英単語を入力し「AIで生成」ボタンで意味・例文を自動生成（Claude API使用）
- 例文は2種類作成し、それぞれ日本語訳を付ける
- 生成後はユーザーが編集可能
- 単語の重複チェックを行う（大文字小文字を区別しない）

### 単語帳
- 単語一覧をソート可能（登録日・アルファベット順・正答率）
- 単語詳細・編集・削除機能
- 出典情報（書籍・サイトURL・動画URLなど + ページ数・詳細）を保存可能
  - 出典情報は今後項目が増える可能性があるため、拡張しやすい設計にする

### 単語テスト（クイズ）
- 1回20問
- 優先度: 未テストの単語 > 正答率が低い単語
- 回答形式: 覚えている / 覚えていない（二択）
- テスト形式は今後変更の可能性があるため、変更しやすく設計する

### 実績（ストリーク）
- 連続学習日数を表示
- 過去の学習履歴をカレンダー表示

### エクスポート/インポート
- JSON・CSV 両形式に対応
- インポート時は重複単語をスキップし、件数を報告

---

## コーディングルール

### ディレクトリ設計方針
```
src/language_learn/
├── core/          # 共通基盤（DB接続・ベースモデル・例外）
└── features/      # 機能別モジュール
    ├── words/     # 単語帳機能
    ├── ai/        # AI連携
    ├── quiz/      # テスト機能
    ├── streak/    # 実績機能
    └── export/    # エクスポート/インポート
```

### 依存方向（循環参照禁止）
```
core ← features/* (words, ai, quiz, streak, export)
words ← quiz, export
quiz ← export
streak ← export
```
- features 同士は一方向のみ
- 逆方向・循環は絶対禁止

### コメント規則
- ソースファイルトップに概要コメントを必ず記載
- クラス・関数・変数（重要なもの）にコメントを記載
- 「何をするか」ではなく「なぜそうするか」を説明する

### その他
- コードの重複は避け、共通処理は core/ に集約
- 各機能実装後に git commit すること
- 新機能追加・変更後は README.md をアップデートすること
- 今後の開発指示はこのファイル（skill_app_dev.md）に追記すること

---

## 今後の開発に向けた注意事項
- 対応言語の追加（フランス語・スペイン語など）は config で言語ペアを管理する想定
- テスト形式の変更（選択肢式・穴埋め式など）は quiz/service.py の word_selection と quiz/router.py を変更
- 出典情報の項目追加は word_sources テーブルの追加カラム or word_source_attributes テーブル（EAV）で対応
- UI のテーマ変更は templates/base.html と static/css/app.css を変更

### AI プロバイダーの追加方法
新しい AI プロバイダー（例: Groq, Mistral）を追加する場合:
1. `features/ai/providers/` に `{name}.py` を作成し `BaseAIProvider` を継承
2. `generate_word_info()` を実装する
3. `features/ai/service.py` の `get_ai_provider()` に分岐を追加する
4. `config.py` の `ai_provider` の `Literal` 型に名前を追加する
5. `.env.example` に新しいキー設定例を追加する

現在の対応プロバイダー:
- `claude` — Anthropic Claude API（要: ANTHROPIC_API_KEY）
- `gemini` — Google Gemini API（要: GOOGLE_API_KEY、無料枠あり）
