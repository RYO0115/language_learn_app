# Language Learn App — スマートフォンアプリ

Flutter 製の英語学習単語帳アプリです。  
AI（Google Gemini または Anthropic Claude）が意味・発音記号・例文を自動生成します。

---

## 目次

1. [必要条件](#必要条件)
2. [セットアップ](#セットアップ)
3. [実行方法](#実行方法)
   - [iOS シミュレーター](#ios-シミュレーター推奨)
   - [iOS 実機](#ios-実機)
   - [Android](#android)
4. [ビルドのみ実行する](#ビルドのみ実行する)
5. [開発中の便利コマンド](#開発中の便利コマンド)
6. [初回起動時の設定（APIキー）](#初回起動時の設定apiキー)
7. [動作確認（APIキーあり／なし切り替え）](#動作確認apiキーありなし切り替え)
8. [ディレクトリ構成](#ディレクトリ構成)
9. [技術スタック](#技術スタック)

---

## 必要条件

| ツール | バージョン | 確認コマンド |
|--------|-----------|-------------|
| Flutter SDK | 3.x 以上 | `flutter --version` |
| Dart SDK | 3.x 以上 | `dart --version` |
| Xcode | 14 以上（iOS 向け） | `xcode-select --version` |
| Android SDK | API 21 以上（Android 向け） | `flutter doctor` |

環境の問題は `flutter doctor` で一覧確認できます。

```bash
flutter doctor
```

---

## セットアップ

```bash
# 1. このディレクトリに移動
cd smartphone_app

# 2. 依存パッケージをインストール
flutter pub get
```

---

## 実行方法

すべてのコマンドは `smartphone_app/` ディレクトリ内で実行してください。

### iOS シミュレーター（推奨）

```bash
# 利用可能なシミュレーターを一覧表示
xcrun simctl list devices available

# シミュレーターを起動（例: iPhone 17 Pro）
open -a Simulator

# アプリを実行（起動済みシミュレーターに自動接続）
flutter run

# デバイスを指定して実行
flutter run -d "iPhone 17 Pro"
```

### iOS 実機

1. Xcode で Apple Developer アカウントを設定する
2. デバイスを Mac に接続する
3. 以下を実行する

```bash
flutter run -d <device-id>
```

デバイス ID は `flutter devices` で確認できます。

### Android

Android SDK と Android エミュレーター（または実機）が必要です。

```bash
# 接続済みデバイス／エミュレーターを確認
flutter devices

# 実行
flutter run -d <device-id>
```

> **注意:** Android SDK が未インストールの場合、`flutter doctor` の指示に従ってセットアップしてください。

---

## ビルドのみ実行する

```bash
# iOS シミュレーター向けビルド（動作確認）
flutter build ios --simulator

# iOS リリースビルド（実機用 .ipa）
flutter build ios --release

# Android デバッグ APK
flutter build apk --debug

# Android リリース APK
flutter build apk --release
```

---

## 開発中の便利コマンド

`flutter run` 起動中にターミナルで以下のキーが使えます。

| キー | 操作 |
|------|------|
| `r` | ホットリロード（UIの変更を即時反映） |
| `R` | ホットリスタート（状態をリセットして再起動） |
| `q` | アプリを終了 |
| `d` | flutter run を終了（アプリはそのまま残す） |
| `h` | コマンド一覧を表示 |

```bash
# 静的解析（エラー・警告の確認）
flutter analyze

# テストを実行
flutter test
```

---

## 初回起動時の設定（APIキー）

初回起動時は **APIキー設定画面** が表示されます。

1. プロバイダーを選択（Google Gemini 推奨・無料）
2. 表示されている URL をタップしてAPIキーを取得
3. APIキーを入力して「保存して始める」をタップ

| プロバイダー | 無料枠 | 取得先 |
|---|---|---|
| **Google Gemini** | 1,500 リクエスト/日（カード不要）⭐ | https://aistudio.google.com/apikey |
| Anthropic Claude | 有料プランが必要 | https://console.anthropic.com |

---

## 動作確認（APIキーあり／なし切り替え）

**APIキーなし状態に戻す（オンボーディング画面を再表示）:**

1. アプリ内の設定画面（⚙️）を開く
2. Google Gemini / Anthropic Claude のAPIキー欄を**空にして保存**
3. アプリを再起動 → オンボーディング画面が表示される

**APIキーあり状態に戻す:**

1. オンボーディング画面でAPIキーを入力して保存
2. ダッシュボードに遷移する

---

## ディレクトリ構成

```
smartphone_app/
├── lib/
│   ├── main.dart                        # エントリーポイント
│   ├── app.dart                         # ルーティング・テーマ設定
│   ├── l10n/                            # 日本語ローカライズ
│   ├── core/
│   │   ├── database/                    # Drift（SQLite）DB 定義・生成ファイル
│   │   ├── exceptions/                  # カスタム例外
│   │   └── utils/                       # 共通ユーティリティ
│   └── features/
│       ├── ai/                          # AI 生成（Gemini / Claude）
│       ├── dashboard/                   # ダッシュボード画面
│       ├── export/                      # JSON / CSV エクスポート・インポート
│       ├── onboarding/                  # APIキー設定画面
│       ├── quiz/                        # クイズ画面・結果画面
│       ├── settings/                    # 設定画面
│       ├── streak/                      # 学習カレンダー
│       └── words/                       # 単語一覧・詳細・編集画面
├── test/                                # テスト
├── ios/                                 # iOS プロジェクト
├── android/                             # Android プロジェクト
├── pubspec.yaml                         # 依存パッケージ定義
└── l10n.yaml                            # ローカライズ設定
```

---

## 技術スタック

| 項目 | 技術 |
|------|------|
| UI フレームワーク | Flutter 3.x |
| 状態管理 | Riverpod |
| ナビゲーション | go_router |
| ローカル DB | Drift（SQLite） |
| セキュアストレージ | flutter_secure_storage（APIキー保存） |
| HTTP クライアント | Dio |
| AI プロバイダー | Google Gemini 2.0 Flash / Anthropic Claude Haiku |
| エクスポート共有 | share_plus |
| URL起動 | url_launcher |
