import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/settings_repository.dart';
import '../domain/app_settings.dart';

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final repo = ref.watch(settingsRepositoryProvider);
    return repo.load();
  }

  Future<void> save(AppSettings settings) async {
    state = const AsyncLoading();
    final repo = ref.read(settingsRepositoryProvider);
    await repo.save(settings);
    state = AsyncData(settings);
  }
}
