import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ja')];

  /// No description provided for @appTitle.
  ///
  /// In ja, this message translates to:
  /// **'単語帳'**
  String get appTitle;

  /// No description provided for @addWord.
  ///
  /// In ja, this message translates to:
  /// **'単語を追加'**
  String get addWord;

  /// No description provided for @editWord.
  ///
  /// In ja, this message translates to:
  /// **'単語を編集'**
  String get editWord;

  /// No description provided for @deleteWord.
  ///
  /// In ja, this message translates to:
  /// **'単語を削除'**
  String get deleteWord;

  /// No description provided for @wordList.
  ///
  /// In ja, this message translates to:
  /// **'単語一覧'**
  String get wordList;

  /// No description provided for @wordDetail.
  ///
  /// In ja, this message translates to:
  /// **'単語詳細'**
  String get wordDetail;

  /// No description provided for @quizStart.
  ///
  /// In ja, this message translates to:
  /// **'クイズを開始'**
  String get quizStart;

  /// No description provided for @quizResult.
  ///
  /// In ja, this message translates to:
  /// **'クイズ結果'**
  String get quizResult;

  /// No description provided for @streak.
  ///
  /// In ja, this message translates to:
  /// **'学習カレンダー'**
  String get streak;

  /// No description provided for @exportImport.
  ///
  /// In ja, this message translates to:
  /// **'エクスポート / インポート'**
  String get exportImport;

  /// No description provided for @settings.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get settings;

  /// No description provided for @dashboard.
  ///
  /// In ja, this message translates to:
  /// **'ダッシュボード'**
  String get dashboard;

  /// No description provided for @onboardingTitle.
  ///
  /// In ja, this message translates to:
  /// **'AI プロバイダーを設定してください'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'単語情報の自動生成に必要です'**
  String get onboardingSubtitle;

  /// No description provided for @settingsApiKey.
  ///
  /// In ja, this message translates to:
  /// **'API キー'**
  String get settingsApiKey;

  /// No description provided for @settingsAiProvider.
  ///
  /// In ja, this message translates to:
  /// **'AI プロバイダー'**
  String get settingsAiProvider;

  /// No description provided for @settingsQuizCount.
  ///
  /// In ja, this message translates to:
  /// **'クイズ出題数'**
  String get settingsQuizCount;

  /// No description provided for @settingsDbLimit.
  ///
  /// In ja, this message translates to:
  /// **'DB 上限 (MB)'**
  String get settingsDbLimit;

  /// No description provided for @providerGemini.
  ///
  /// In ja, this message translates to:
  /// **'Google Gemini（推奨・無料）'**
  String get providerGemini;

  /// No description provided for @providerClaude.
  ///
  /// In ja, this message translates to:
  /// **'Anthropic Claude'**
  String get providerClaude;

  /// No description provided for @save.
  ///
  /// In ja, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @saveAndStart.
  ///
  /// In ja, this message translates to:
  /// **'保存して始める'**
  String get saveAndStart;

  /// No description provided for @cancel.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ja, this message translates to:
  /// **'削除'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In ja, this message translates to:
  /// **'確認'**
  String get confirm;

  /// No description provided for @ok.
  ///
  /// In ja, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @known.
  ///
  /// In ja, this message translates to:
  /// **'知っていた'**
  String get known;

  /// No description provided for @unknown.
  ///
  /// In ja, this message translates to:
  /// **'知らなかった'**
  String get unknown;

  /// No description provided for @correctRate.
  ///
  /// In ja, this message translates to:
  /// **'正答率'**
  String get correctRate;

  /// No description provided for @studyDays.
  ///
  /// In ja, this message translates to:
  /// **'学習日数'**
  String get studyDays;

  /// No description provided for @currentStreak.
  ///
  /// In ja, this message translates to:
  /// **'連続学習日数'**
  String get currentStreak;

  /// No description provided for @totalWords.
  ///
  /// In ja, this message translates to:
  /// **'登録単語数'**
  String get totalWords;

  /// No description provided for @exportJson.
  ///
  /// In ja, this message translates to:
  /// **'JSON エクスポート'**
  String get exportJson;

  /// No description provided for @exportCsv.
  ///
  /// In ja, this message translates to:
  /// **'CSV エクスポート'**
  String get exportCsv;

  /// No description provided for @importJson.
  ///
  /// In ja, this message translates to:
  /// **'JSON インポート'**
  String get importJson;

  /// No description provided for @importCsv.
  ///
  /// In ja, this message translates to:
  /// **'CSV インポート'**
  String get importCsv;

  /// No description provided for @duplicateSkipped.
  ///
  /// In ja, this message translates to:
  /// **'重複した単語はスキップされました'**
  String get duplicateSkipped;

  /// No description provided for @storageLimitWarning.
  ///
  /// In ja, this message translates to:
  /// **'データベースのサイズが上限（{limitMb}MB）を超えています。続行しますか？'**
  String storageLimitWarning(int limitMb);

  /// No description provided for @geminiGuide.
  ///
  /// In ja, this message translates to:
  /// **'1. aistudio.google.com/apikey を開く\n2. Google アカウントでログイン\n3.「API キーを作成」を押してコピー\n\n無料枠: 1,500 リクエスト/日・30 リクエスト/分'**
  String get geminiGuide;

  /// No description provided for @claudeGuide.
  ///
  /// In ja, this message translates to:
  /// **'1. console.anthropic.com を開く\n2. 「API Keys」からキーを発行\n\n※ 有料プランが必要です'**
  String get claudeGuide;

  /// No description provided for @wordField.
  ///
  /// In ja, this message translates to:
  /// **'英単語'**
  String get wordField;

  /// No description provided for @readingField.
  ///
  /// In ja, this message translates to:
  /// **'発音記号'**
  String get readingField;

  /// No description provided for @meaningField.
  ///
  /// In ja, this message translates to:
  /// **'意味'**
  String get meaningField;

  /// No description provided for @partOfSpeechField.
  ///
  /// In ja, this message translates to:
  /// **'品詞'**
  String get partOfSpeechField;

  /// No description provided for @exampleSentence.
  ///
  /// In ja, this message translates to:
  /// **'例文'**
  String get exampleSentence;

  /// No description provided for @exampleSentenceEn.
  ///
  /// In ja, this message translates to:
  /// **'英語例文'**
  String get exampleSentenceEn;

  /// No description provided for @exampleSentenceJa.
  ///
  /// In ja, this message translates to:
  /// **'日本語訳'**
  String get exampleSentenceJa;

  /// No description provided for @addExampleSentence.
  ///
  /// In ja, this message translates to:
  /// **'例文を追加'**
  String get addExampleSentence;

  /// No description provided for @wordSource.
  ///
  /// In ja, this message translates to:
  /// **'出典'**
  String get wordSource;

  /// No description provided for @addWordSource.
  ///
  /// In ja, this message translates to:
  /// **'出典を追加'**
  String get addWordSource;

  /// No description provided for @generateWithAi.
  ///
  /// In ja, this message translates to:
  /// **'AI で生成'**
  String get generateWithAi;

  /// No description provided for @generating.
  ///
  /// In ja, this message translates to:
  /// **'生成中...'**
  String get generating;

  /// No description provided for @aiGenerateError.
  ///
  /// In ja, this message translates to:
  /// **'AI 生成に失敗しました'**
  String get aiGenerateError;

  /// No description provided for @duplicateWordError.
  ///
  /// In ja, this message translates to:
  /// **'この単語はすでに登録されています'**
  String get duplicateWordError;

  /// No description provided for @required.
  ///
  /// In ja, this message translates to:
  /// **'必須項目です'**
  String get required;

  /// No description provided for @noWordsYet.
  ///
  /// In ja, this message translates to:
  /// **'単語が登録されていません'**
  String get noWordsYet;

  /// No description provided for @searchWords.
  ///
  /// In ja, this message translates to:
  /// **'単語を検索'**
  String get searchWords;

  /// No description provided for @sessionCompleted.
  ///
  /// In ja, this message translates to:
  /// **'セッション完了'**
  String get sessionCompleted;

  /// No description provided for @questionsCount.
  ///
  /// In ja, this message translates to:
  /// **'{count}問'**
  String questionsCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
