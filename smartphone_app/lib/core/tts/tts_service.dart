import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../features/settings/domain/app_settings.dart';
import '../../features/settings/presentation/settings_provider.dart';

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService(ref);
  ref.onDispose(service.dispose);
  return service;
});

class TtsService {
  TtsService(this._ref);

  final Ref _ref;
  final _tts = FlutterTts();

  Future<void> speak(String text) async {
    final settings = _ref.read(settingsProvider).valueOrNull;
    final locale =
        settings?.ttsAccent == TtsAccent.british ? 'en-GB' : 'en-US';
    await _tts.stop();
    await _tts.setLanguage(locale);
    await _tts.speak(text);
  }

  void dispose() => _tts.stop();
}
