# スマートフォンアプリ 技術設計書

バージョン: 1.1.0  
作成日: 2026-05-19  
更新日: 2026-05-19（API キーオンボーディング・i18n・バックアップ抽象化・iOS 最小バージョン確定）

---

## 1. 技術スタック

### 1.1 採用技術: Flutter（Dart）

**選定理由**

| 項目 | 内容 |
|------|------|
| iOS / Android 共通 | 単一コードベースで両プラットフォームのネイティブアプリを生成できる |
| UI 共有 | React Native と異なり、描画エンジンも共通（プラットフォーム UI に依存しない） |
| ローカル SQLite | `drift`（型安全な ORM）で現行 Python のスキーマをほぼそのまま移植できる |
| パフォーマンス | AOT コンパイルで高速。60fps のスムーズな UI |
| 広告対応 | Google AdMob の Flutter プラグインが公式提供されている |
| テスト | unit / widget / integration の3層テストが標準で揃っている |

### 1.2 主要パッケージ

| 用途 | パッケージ |
|------|-----------|
| ローカル DB | `drift` + `sqlite3_flutter_libs` |
| 状態管理 | `flutter_riverpod` |
| 安全なストレージ | `flutter_secure_storage`（API キー保存） |
| HTTP クライアント | `dio` |
| ナビゲーション | `go_router` |
| エクスポート共有 | `share_plus` + `path_provider` |
| ファイル選択 | `file_picker` |
| テスト | `flutter_test` + `integration_test` + `mocktail` |
| 多言語 | `flutter_localizations` + `intl`（ARB ファイル管理） |
| 将来（広告） | `google_mobile_ads` |
| 将来（バックアップ） | `icloud_storage`（iOS）/ `googleapis`（Android）|

---

## 2. リポジトリ構成

現行の Python アプリとスマートフォンアプリは別ディレクトリに分離する。

```
language_learn_app/          ← リポジトリルート（既存）
├── docs/                    ← 設計ドキュメント
├── server_app/              ← 既存 Python アプリを移動
│   ├── src/
│   ├── templates/
│   ├── static/
│   ├── pyproject.toml
│   └── ...
└── smartphone_app/          ← 新規 Flutter アプリ
    ├── lib/
    ├── test/
    ├── android/
    ├── ios/
    └── pubspec.yaml
```

---

## 3. Flutter アプリ ディレクトリ構成

Feature-first（機能ごとにディレクトリを切る）を採用する。
各機能は `data / domain / presentation` の3層に分ける。

```
smartphone_app/lib/
├── main.dart                        ← エントリーポイント
├── app.dart                         ← ルーティング・テーマ設定
│
├── core/                            ← 全機能共通の基盤
│   ├── database/
│   │   ├── app_database.dart        ← drift DB 定義（テーブル・クエリ）
│   │   └── app_database.g.dart      ← 自動生成コード
│   ├── exceptions/
│   │   └── app_exception.dart       ← カスタム例外クラス
│   └── utils/
│       ├── storage_monitor.dart     ← DB 容量チェックロジック
│       └── date_utils.dart
│
└── features/
    ├── words/                       ← 単語管理機能
    │   ├── data/
    │   │   ├── word_repository.dart
    │   │   └── word_dao.dart        ← drift DAO
    │   ├── domain/
    │   │   ├── word.dart            ← エンティティ
    │   │   ├── example_sentence.dart
    │   │   └── word_source.dart
    │   └── presentation/
    │       ├── word_list_page.dart
    │       ├── word_detail_page.dart
    │       ├── word_edit_page.dart
    │       └── word_list_provider.dart   ← Riverpod Provider
    │
    ├── quiz/                        ← クイズ機能
    │   ├── data/
    │   │   ├── quiz_repository.dart
    │   │   └── quiz_dao.dart
    │   ├── domain/
    │   │   ├── quiz_session.dart
    │   │   └── quiz_answer.dart
    │   └── presentation/
    │       ├── quiz_page.dart
    │       ├── quiz_result_page.dart
    │       └── quiz_provider.dart
    │
    ├── streak/                      ← 学習記録機能
    │   ├── data/
    │   │   ├── streak_repository.dart
    │   │   └── streak_dao.dart
    │   ├── domain/
    │   │   └── study_record.dart
    │   └── presentation/
    │       ├── streak_calendar_page.dart
    │       └── streak_provider.dart
    │
    ├── ai/                          ← AI 生成機能
    │   ├── data/
    │   │   ├── ai_service.dart           ← ファクトリー
    │   │   └── providers/
    │   │       ├── base_ai_provider.dart ← 抽象クラス
    │   │       ├── claude_provider.dart
    │   │       └── gemini_provider.dart
    │   └── domain/
    │       └── ai_generate_response.dart
    │
    ├── export/                      ← エクスポート / インポート機能
    │   ├── data/
    │   │   └── export_service.dart
    │   └── presentation/
    │       └── export_page.dart
    │
    ├── settings/                    ← 設定機能
    │   ├── data/
    │   │   └── settings_repository.dart ← secure_storage でキー保存
    │   ├── domain/
    │   │   └── app_settings.dart
    │   └── presentation/
    │       ├── settings_page.dart
    │       └── settings_provider.dart
    │
    ├── onboarding/                  ← API キー初回設定
    │   └── presentation/
    │       └── api_key_setup_page.dart
    │
    ├── backup/                      ← バックアップ抽象レイヤー（将来実装）
    │   └── data/
    │       ├── backup_repository.dart       ← 抽象クラス
    │       └── no_op_backup_repository.dart ← Phase1: 何もしない実装
    │
    └── dashboard/                   ← ダッシュボード
        └── presentation/
            ├── dashboard_page.dart
            └── dashboard_provider.dart
```

> **i18n ファイル配置**
> ```
> smartphone_app/
> └── lib/
>     └── l10n/
>         └── app_ja.arb    ← 日本語リソース（全 UI 文字列をここで管理）
> ```
> 将来言語を追加する場合は `app_en.arb` などを追加するだけでよい。

---

## 4. クラス設計

### 4.1 データ層（DAO）

```
WordDao          - words / example_sentences / word_sources を操作
QuizDao          - quiz_sessions / quiz_answers を操作
StreakDao         - study_records を操作
```

各 DAO は drift の `DatabaseAccessor` を継承し、SQL クエリをメソッドとして持つ。
Repository クラスが DAO をラップして、ドメイン層に型安全なエンティティを返す。

### 4.2 ドメイン層（エンティティ）

```dart
// features/words/domain/word.dart
class Word {
  final int id;
  final String word;
  final String? reading;
  final String meaning;
  final String? partOfSpeech;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ExampleSentence> exampleSentences;
  final List<WordSource> sources;
}
```

```dart
// features/quiz/domain/quiz_session.dart
class QuizSession {
  final int id;
  final DateTime startedAt;
  final DateTime? completedAt;
}
```

### 4.3 AI プロバイダー（Strategyパターン）

```dart
// features/ai/data/providers/base_ai_provider.dart
abstract class BaseAiProvider {
  Future<AiGenerateResponse> generateWordInfo(String word);
}

// features/ai/data/providers/claude_provider.dart
class ClaudeProvider implements BaseAiProvider { ... }

// features/ai/data/providers/gemini_provider.dart
class GeminiProvider implements BaseAiProvider { ... }

// features/ai/data/ai_service.dart
class AiService {
  BaseAiProvider getProvider(AppSettings settings) {
    return switch (settings.aiProvider) {
      AiProvider.claude => ClaudeProvider(apiKey: settings.claudeApiKey),
      AiProvider.gemini => GeminiProvider(apiKey: settings.googleApiKey),
    };
  }
}
```

### 4.4 ストレージ監視

```dart
// core/utils/storage_monitor.dart
class StorageMonitor {
  final int limitBytes;           // デフォルト 100 * 1024 * 1024

  Future<int> getDatabaseSizeBytes();
  Future<bool> isOverLimit();
  Future<StorageStatus> check();  // ok / warning / over
}
```

呼び出しタイミング:
- アプリ起動時（cold start）
- 単語追加・インポート前

閾値超過時はダイアログを表示。ユーザーが「OK」を選択した場合は登録を続行。

### 4.5 API キー初回設定フロー（オンボーディング）

アプリ起動時に go_router のリダイレクトで未設定を検出し、設定完了まで他の画面へ遷移させない。

```dart
// app.dart（router の redirect）
redirect: (context, state) {
  final hasKey = ref.read(settingsProvider).hasAnyApiKey;
  final isOnboarding = state.matchedLocation == '/onboarding';
  if (!hasKey && !isOnboarding) return '/onboarding';
  if (hasKey && isOnboarding) return '/';
  return null;
},
```

**API キー設定画面のコンテンツ構成**

```
┌──────────────────────────────────────────┐
│  AI プロバイダーを選択してください           │
│  ○ Google Gemini（推奨・無料）             │
│  ○ Anthropic Claude                       │
│                                          │
│  API キー                                 │
│  [ _________________________ ] 👁         │
│                                          │
│  ── 取得方法 ──────────────────────────   │
│  【Google Gemini（無料・カード不要）】      │
│  1. aistudio.google.com/apikey を開く     │
│  2. Google アカウントでログイン            │
│  3. 「API キーを作成」を押してコピー        │
│  無料枠: 1,500 req/日・30 req/分          │
│                                          │
│  【Anthropic Claude（有料プラン必要）】    │
│  1. console.anthropic.com を開く          │
│  2. 「API Keys」からキーを発行             │
│                                          │
│         [ 保存して始める ]                 │
└──────────────────────────────────────────┘
```

### 4.6 多言語対応（i18n）設計

UI テキストをハードコードせず、すべて ARB ファイル経由で管理する。
これにより、将来の言語追加はリソースファイルの追加と `supportedLocales` への登録のみで対応できる。

```yaml
# pubspec.yaml
flutter:
  generate: true
  # flutter_localizations はここで有効化

flutter_intl:
  enabled: true
  arb_dir: lib/l10n
```

```json
// lib/l10n/app_ja.arb（抜粋）
{
  "appTitle": "単語帳",
  "addWord": "単語を追加",
  "quizStart": "クイズを開始",
  "settingsApiKey": "API キー",
  "onboardingTitle": "AI プロバイダーを設定してください",
  "onboardingGeminiGuide": "1. aistudio.google.com/apikey を開く\n2. Google アカウントでログイン\n3.「API キーを作成」を押してコピー",
  "storageLimitWarning": "データベースのサイズが上限（{limitMb}MB）を超えています。続行しますか？",
  "@storageLimitWarning": {
    "placeholders": { "limitMb": { "type": "int" } }
  }
}
```

将来 `app_en.arb` を追加すれば英語対応が完了する。

### 4.7 バックアップ抽象レイヤー

Phase 1 では何もしない実装（`NoOpBackupRepository`）を注入する。
iCloud 対応時は `ICloudBackupRepository` を実装して差し替えるだけでよい。

```dart
// features/backup/data/backup_repository.dart
abstract class BackupRepository {
  Future<void> upload(File dbFile);       // クラウドへ保存
  Future<File?> downloadLatest();         // 最新バックアップを取得
  Future<DateTime?> lastBackupDate();     // 最終バックアップ日時
}

// features/backup/data/no_op_backup_repository.dart（Phase 1）
class NoOpBackupRepository implements BackupRepository {
  @override Future<void> upload(File _) async {}
  @override Future<File?> downloadLatest() async => null;
  @override Future<DateTime?> lastBackupDate() async => null;
}

// 将来（iOS Phase 3）
// class ICloudBackupRepository implements BackupRepository { ... }
// 将来（Android Phase 4）
// class DriveBackupRepository implements BackupRepository { ... }
```

Riverpod で DI する：

```dart
final backupRepositoryProvider = Provider<BackupRepository>(
  (ref) => NoOpBackupRepository(), // Phase3で差し替え
);
```

### 4.8 状態管理（Riverpod）

```dart
// Provider 例
final wordListProvider = AsyncNotifierProvider<WordListNotifier, List<Word>>(
  WordListNotifier.new,
);

final quizSessionProvider = StateNotifierProvider<QuizNotifier, QuizState>(
  (ref) => QuizNotifier(ref.watch(quizRepositoryProvider)),
);

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
```

---

## 5. 画面遷移

```
/onboarding              ← API キー初回設定（未設定時のみ。設定完了で / へ）
/                        ← ダッシュボード
/words                   ← 単語一覧
/words/:id               ← 単語詳細
/words/add               ← 単語追加
/words/:id/edit          ← 単語編集
/quiz                    ← クイズ（問題画面）
/quiz/result/:sessionId  ← クイズ結果
/streak                  ← 学習カレンダー
/export                  ← エクスポート / インポート
/settings                ← 設定
```

go_router の `redirect` フックで API キーの有無を起動時に確認し、
未設定の場合は `/onboarding` へ強制リダイレクトする。設定完了後は通常フローへ復帰する。

---

## 6. データベース（drift）

```dart
// core/database/app_database.dart

@DriftDatabase(tables: [Words, ExampleSentences, WordSources,
                         QuizSessions, QuizAnswers, StudyRecords])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override int get schemaVersion => 1;
}

class Words extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get word => text().withLength(max: 100).unique()();
  TextColumn get reading => text().nullable()();
  TextColumn get meaning => text()();
  TextColumn get partOfSpeech => text().nullable()();
  IntColumn get createdAt => integer()(); // Unix timestamp
  IntColumn get updatedAt => integer()();
}
```

---

## 7. テスト戦略

### 7.1 テスト種別と対象

| テスト種別 | 対象 | ツール |
|-----------|------|--------|
| ユニットテスト | Repository / Service / ロジック | `flutter_test` + `mocktail` |
| ウィジェットテスト | 各 Page / Widget | `flutter_test` |
| 統合テスト | E2E（実機 / エミュレーター） | `integration_test` |

### 7.2 リグレッションテスト一覧（機能 ID 対応）

| テストID | 機能ID | テスト内容 |
|---------|--------|-----------|
| T-W-01 | W-01 | 単語を正常に追加できる |
| T-W-02 | W-01 | 重複単語を追加するとエラーになる |
| T-W-03 | W-02 | 単語を正常に編集できる |
| T-W-04 | W-03 | 単語を削除すると例文・出典も削除される |
| T-W-05 | W-04 | 単語一覧が正しく表示される |
| T-W-06 | W-06 | 重複チェックが機能する |
| T-Q-01 | Q-03 | 未テスト単語が優先して出題される |
| T-Q-02 | Q-03 | 低正答率の単語が次に出題される |
| T-Q-03 | Q-04 | 回答が正しく記録される |
| T-Q-04 | Q-05 | クイズ結果（正答率）が正しく集計される |
| T-S-01 | S-01 | クイズ完了時に学習記録が登録される |
| T-S-02 | S-03 | 連続学習日数が正しく算出される |
| T-E-01 | E-01 | JSON エクスポートが正しいフォーマットで出力される |
| T-E-02 | E-03 | JSON インポートで重複単語がスキップされる |
| T-E-03 | E-02 | CSV エクスポートが正しいフォーマットで出力される |
| T-E-04 | E-04 | CSV インポートで重複単語がスキップされる |
| T-ST-01 | ST-01 | DB 容量が正しく取得できる |
| T-ST-02 | ST-02 | 上限超過時に警告ダイアログが表示される |
| T-ST-03 | ST-03 | 警告後「OK」を選択すると登録が続行される |
| T-ST-04 | ST-04 | 上限値の変更が保存・反映される |
| T-A-01 | A-01 | Claude プロバイダーが正しいフォーマットで返答する（モック） |
| T-A-02 | A-01 | Gemini プロバイダーが正しいフォーマットで返答する（モック） |
| T-A-03 | A-02 | プロバイダーを切り替えると使用するクラスが変わる |
| T-A-04 | A-04 | API キー未設定時にオンボーディング画面へリダイレクトされる |
| T-A-05 | A-04 | API キー設定後にダッシュボードへ遷移できる |

### 7.3 CI 自動実行

GitHub Actions で以下のタイミングにテストを自動実行する。

```yaml
# .github/workflows/flutter_test.yml
on:
  push:
    branches: [feature/**, fix/**]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
        working-directory: smartphone_app
      - run: flutter test
        working-directory: smartphone_app
      - run: flutter analyze
        working-directory: smartphone_app
```

---

## 8. セキュリティ設計

| 項目 | 実装方針 |
|------|---------|
| API キー | `flutter_secure_storage` でキーチェーン / Android Keystore に保存 |
| DB ファイル | デバイスのアプリサンドボックス内に配置（外部アクセス不可） |
| ネットワーク | AI API 呼び出しのみ。HTTPS 必須 |
| エクスポートデータ | ユーザーが意図的に共有しない限り端末外へ出ない |

---

## 9. 広告実装方針（Phase 3）

- `google_mobile_ads` パッケージを使用する
- 初期リリースでは広告なし（コードのみ準備）
- 広告表示タイミング（候補）:
  - クイズ結果画面（バナー広告）
  - 単語一覧画面最下部（バナー広告）
  - クイズ終了後（インタースティシャル広告）
- 広告 Unit ID は設定ファイル（`lib/core/constants/ad_constants.dart`）で一元管理する

---

## 10. 移行計画

| フェーズ | 作業内容 |
|---------|---------|
| Phase 0（準備） | `server_app/` へ既存 Python アプリを移動 / `smartphone_app/` を Flutter で初期化 |
| Phase 1（基盤） | DB スキーマ定義 / コア機能（単語 CRUD・クイズ・ストリーク）実装 |
| Phase 2（完成） | AI 生成・エクスポート・設定・ストレージ監視 / テスト整備 / CI 構築 |
| Phase 3（リリース） | App Store 申請 / TestFlight 配布 |
| Phase 4（Android） | Android 動作確認 / Google Play 申請 |
| Phase 5（収益化） | AdMob 広告組み込み / 公開 |

---

## 11. 確定済み仕様

| 項目 | 決定内容 |
|------|---------|
| API キーの調達 | ユーザー自身が取得（アプリ側プロキシなし）。未設定時はオンボーディング画面を表示 |
| バックアップ | Phase 3 以降で iCloud / Google Drive を検討。Phase 1 は NoOpBackupRepository で対応 |
| UI 言語 | 日本語のみ（Phase 3 以降で多言語化。ARB ファイルで文字列を一元管理） |
| 最小 iOS バージョン | iOS 16 |

