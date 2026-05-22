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

  Future<AppSettings> load() async {
    final provider = await _storage.read(key: _keyProvider);
    final googleKey = await _storage.read(key: _keyGoogleApiKey);
    final claudeKey = await _storage.read(key: _keyClaudeApiKey);
    final quizCount = await _storage.read(key: _keyQuizCount);
    final dbLimit = await _storage.read(key: _keyDbLimitMb);

    return AppSettings(
      aiProvider: provider == AiProvider.claude.name
          ? AiProvider.claude
          : AiProvider.gemini,
      googleApiKey: googleKey,
      claudeApiKey: claudeKey,
      quizCount: int.tryParse(quizCount ?? '') ?? 20,
      dbLimitMb: int.tryParse(dbLimit ?? '') ?? 100,
    );
  }

  Future<void> save(AppSettings settings) async {
    await _storage.write(
        key: _keyProvider, value: settings.aiProvider.name);
    if (settings.googleApiKey != null) {
      await _storage.write(
          key: _keyGoogleApiKey, value: settings.googleApiKey);
    }
    if (settings.claudeApiKey != null) {
      await _storage.write(
          key: _keyClaudeApiKey, value: settings.claudeApiKey);
    }
    await _storage.write(
        key: _keyQuizCount, value: settings.quizCount.toString());
    await _storage.write(
        key: _keyDbLimitMb, value: settings.dbLimitMb.toString());
  }
}
