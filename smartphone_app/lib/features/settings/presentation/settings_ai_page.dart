import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_learn_app/l10n/app_localizations.dart';
import '../../../common/widgets/common_app_bar_actions.dart';
import '../domain/app_settings.dart';
import 'settings_provider.dart';

class SettingsAiPage extends ConsumerStatefulWidget {
  const SettingsAiPage({super.key});

  @override
  ConsumerState<SettingsAiPage> createState() => _SettingsAiPageState();
}

class _SettingsAiPageState extends ConsumerState<SettingsAiPage> {
  final _googleKeyCtrl = TextEditingController();
  final _claudeKeyCtrl = TextEditingController();
  AiProvider _provider = AiProvider.gemini;
  bool _obscureGoogle = true;
  bool _obscureClaude = true;
  bool _initialized = false;

  @override
  void dispose() {
    _googleKeyCtrl.dispose();
    _claudeKeyCtrl.dispose();
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
          _provider = settings.aiProvider;
          _googleKeyCtrl.text = settings.googleApiKey ?? '';
          _claudeKeyCtrl.text = settings.claudeApiKey ?? '';
          _initialized = true;
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('AI 設定'),
            actions: const [CommonAppBarActions(showSettingsButton: false)],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.settingsAiProvider,
                    style: Theme.of(context).textTheme.titleMedium),
                RadioGroup<AiProvider>(
                  groupValue: _provider,
                  onChanged: (v) => setState(() => _provider = v!),
                  child: Column(
                    children: [
                      RadioListTile<AiProvider>(
                        title: Text(l10n.providerGemini),
                        value: AiProvider.gemini,
                      ),
                      RadioListTile<AiProvider>(
                        title: Text(l10n.providerClaude),
                        value: AiProvider.claude,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('Google Gemini API キー',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _googleKeyCtrl,
                  obscureText: _obscureGoogle,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureGoogle
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _obscureGoogle = !_obscureGoogle),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Anthropic Claude API キー',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _claudeKeyCtrl,
                  obscureText: _obscureClaude,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureClaude
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _obscureClaude = !_obscureClaude),
                    ),
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
      aiProvider: _provider,
      googleApiKey:
          _googleKeyCtrl.text.isEmpty ? null : _googleKeyCtrl.text,
      claudeApiKey:
          _claudeKeyCtrl.text.isEmpty ? null : _claudeKeyCtrl.text,
      quizCount: current.quizCount,
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
