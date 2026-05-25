// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '単語帳';

  @override
  String get addWord => '単語を追加';

  @override
  String get editWord => '単語を編集';

  @override
  String get deleteWord => '単語を削除';

  @override
  String get wordList => '単語一覧';

  @override
  String get wordDetail => '単語詳細';

  @override
  String get quizStart => 'クイズを開始';

  @override
  String get quizResult => 'クイズ結果';

  @override
  String get streak => '学習カレンダー';

  @override
  String get exportImport => 'エクスポート / インポート';

  @override
  String get settings => '設定';

  @override
  String get dashboard => 'ダッシュボード';

  @override
  String get onboardingTitle => 'AI プロバイダーを設定してください';

  @override
  String get onboardingSubtitle => '単語情報の自動生成に必要です';

  @override
  String get settingsApiKey => 'API キー';

  @override
  String get settingsAiProvider => 'AI プロバイダー';

  @override
  String get settingsQuizCount => 'クイズ出題数';

  @override
  String get settingsDbLimit => 'DB 上限 (MB)';

  @override
  String get providerGemini => 'Google Gemini（推奨・無料）';

  @override
  String get providerClaude => 'Anthropic Claude';

  @override
  String get save => '保存';

  @override
  String get saveAndStart => '保存して始める';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get confirm => '確認';

  @override
  String get ok => 'OK';

  @override
  String get known => '知っていた';

  @override
  String get unknown => '知らなかった';

  @override
  String get correctRate => '正答率';

  @override
  String get studyDays => '学習日数';

  @override
  String get currentStreak => '連続学習日数';

  @override
  String get totalWords => '登録単語数';

  @override
  String get exportJson => 'JSON エクスポート';

  @override
  String get exportCsv => 'CSV エクスポート';

  @override
  String get importJson => 'JSON インポート';

  @override
  String get importCsv => 'CSV インポート';

  @override
  String get duplicateSkipped => '重複した単語はスキップされました';

  @override
  String storageLimitWarning(int limitMb) {
    return 'データベースのサイズが上限（${limitMb}MB）を超えています。続行しますか？';
  }

  @override
  String get geminiGuide =>
      '1. aistudio.google.com/apikey を開く\n2. Google アカウントでログイン\n3.「API キーを作成」を押してコピー\n\n無料枠: 1,500 リクエスト/日・30 リクエスト/分';

  @override
  String get claudeGuide =>
      '1. console.anthropic.com を開く\n2. 「API Keys」からキーを発行\n\n※ 有料プランが必要です';

  @override
  String get wordField => '英単語';

  @override
  String get readingField => '発音記号';

  @override
  String get meaningField => '意味';

  @override
  String get partOfSpeechField => '品詞';

  @override
  String get exampleSentence => '例文';

  @override
  String get exampleSentenceEn => '英語例文';

  @override
  String get exampleSentenceJa => '日本語訳';

  @override
  String get addExampleSentence => '例文を追加';

  @override
  String get wordSource => '出典';

  @override
  String get addWordSource => '出典を追加';

  @override
  String get generateWithAi => 'AI で生成';

  @override
  String get generating => '生成中...';

  @override
  String get aiGenerateError => 'AI 生成に失敗しました';

  @override
  String get duplicateWordError => 'この単語はすでに登録されています';

  @override
  String get required => '必須項目です';

  @override
  String get noWordsYet => '単語が登録されていません';

  @override
  String get searchWords => '単語を検索';

  @override
  String get sessionCompleted => 'セッション完了';

  @override
  String questionsCount(int count) {
    return '$count問';
  }
}
