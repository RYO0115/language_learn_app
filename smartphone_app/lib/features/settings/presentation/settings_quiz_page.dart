import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_learn_app/l10n/app_localizations.dart';
import '../../../common/widgets/common_app_bar_actions.dart';
import '../domain/app_settings.dart';
import 'settings_provider.dart';

class SettingsQuizPage extends ConsumerStatefulWidget {
  const SettingsQuizPage({super.key});

  @override
  ConsumerState<SettingsQuizPage> createState() => _SettingsQuizPageState();
}

class _SettingsQuizPageState extends ConsumerState<SettingsQuizPage> {
  final _quizCountCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _quizCountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (settings) {
        if (!_initialized) {
          _quizCountCtrl.text = settings.quizCount.toString();
          _initialized = true;
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('クイズ設定'),
            actions: const [CommonAppBarActions(showSettingsButton: false)],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.settingsQuizCount,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _quizCountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    suffixText: '問',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _save,
                  child: Text(l10n.save),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    final current =
        ref.read(settingsProvider).valueOrNull ?? const AppSettings();
    final updated = AppSettings(
      aiProvider: current.aiProvider,
      googleApiKey: current.googleApiKey,
      claudeApiKey: current.claudeApiKey,
      quizCount: int.tryParse(_quizCountCtrl.text) ?? 20,
      dbLimitMb: current.dbLimitMb,
      ttsAccent: current.ttsAccent,
    );
    await ref.read(settingsProvider.notifier).save(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.save)),
      );
    }
  }
}
