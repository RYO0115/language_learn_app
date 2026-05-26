import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/app_settings.dart';

final settingsRepositoryProvider =
    Provider<SettingsRepository>((ref) => SettingsRepository());

class SettingsRepository {
  static const _storage = FlutterSecureStorage();

  static const _keyProvider = 'ai_provider';
  static const _keyGoogleApiKey = 'google_api_key';
  static const _keyClaudeApiKey = 'claude_api_key';
  static const _keyQuizCount = 'quiz_count';
  static const _keyDbLimitMb = 'db_limit_mb';
  static const _keyTtsAccent = 'tts_accent';
  static const _keyAdsEnabled = 'ads_enabled';
  static const _keyIsPremium = 'is_premium';

  Future<AppSettings> load() async {
    final provider = await _storage.read(key: _keyProvider);
    final googleKey = await _storage.read(key: _keyGoogleApiKey);
    final claudeKey = await _storage.read(key: _keyClaudeApiKey);
    final quizCount = await _storage.read(key: _keyQuizCount);
    final dbLimit = await _storage.read(key: _keyDbLimitMb);
    final ttsAccent = await _storage.read(key: _keyTtsAccent);
    final adsEnabled = await _storage.read(key: _keyAdsEnabled);
    final isPremium = await _storage.read(key: _keyIsPremium);

    return AppSettings(
      aiProvider: provider == AiProvider.claude.name
          ? AiProvider.claude
          : AiProvider.gemini,
      googleApiKey: googleKey,
      claudeApiKey: claudeKey,
      quizCount: int.tryParse(quizCount ?? '') ?? 20,
      dbLimitMb: int.tryParse(dbLimit ?? '') ?? 100,
      ttsAccent: ttsAccent == TtsAccent.british.name
          ? TtsAccent.british
          : TtsAccent.american,
      adsEnabled: adsEnabled != 'false',
      isPremium: isPremium == 'true',
    );
  }

  Future<void> save(AppSettings settings) async {
    await _storage.write(
        key: _keyProvider, value: settings.aiProvider.name);
    if (settings.googleApiKey != null && settings.googleApiKey!.isNotEmpty) {
      await _storage.write(
          key: _keyGoogleApiKey, value: settings.googleApiKey);
    } else {
      await _storage.delete(key: _keyGoogleApiKey);
    }
    if (settings.claudeApiKey != null && settings.claudeApiKey!.isNotEmpty) {
      await _storage.write(
          key: _keyClaudeApiKey, value: settings.claudeApiKey);
    } else {
      await _storage.delete(key: _keyClaudeApiKey);
    }
    await _storage.write(
        key: _keyQuizCount, value: settings.quizCount.toString());
    await _storage.write(
        key: _keyDbLimitMb, value: settings.dbLimitMb.toString());
    await _storage.write(
        key: _keyTtsAccent, value: settings.ttsAccent.name);
    await _storage.write(
        key: _keyAdsEnabled, value: settings.adsEnabled.toString());
    await _storage.write(
        key: _keyIsPremium, value: settings.isPremium.toString());
  }
}
