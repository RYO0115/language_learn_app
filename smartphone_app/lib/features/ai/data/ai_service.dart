import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/domain/app_settings.dart';
import 'providers/base_ai_provider.dart';
import 'providers/claude_provider.dart';
import 'providers/gemini_provider.dart';

final aiServiceProvider = Provider<AiService>((ref) => AiService());

class AiService {
  BaseAiProvider getProvider(AppSettings settings) {
    return switch (settings.aiProvider) {
      AiProvider.claude =>
        ClaudeProvider(apiKey: settings.claudeApiKey ?? ''),
      AiProvider.gemini =>
        GeminiProvider(apiKey: settings.googleApiKey ?? ''),
    };
  }
}
