import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:language_learn_app/l10n/app_localizations.dart';
import '../../../common/widgets/common_app_bar_actions.dart';
import '../domain/app_settings.dart';
import 'settings_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _googleKeyCtrl = TextEditingController();
  final _claudeKeyCtrl = TextEditingController();
  final _quizCountCtrl = TextEditingController();
  final _dbLimitCtrl = TextEditingController();
  AiProvider _provider = AiProvider.gemini;
  TtsAccent _ttsAccent = TtsAccent.american;
  bool _obscureGoogle = true;
  bool _obscureClaude = true;
  bool _initialized = false;

  @override
  void dispose() {
    _googleKeyCtrl.dispose();
    _claudeKeyCtrl.dispose();
    _quizCountCtrl.dispose();
    _dbLimitCtrl.dispose();
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
          _ttsAccent = settings.ttsAccent;
          _googleKeyCtrl.text = settings.googleApiKey ?? '';
          _claudeKeyCtrl.text = settings.claudeApiKey ?? '';
          _quizCountCtrl.text = settings.quizCount.toString();
          _dbLimitCtrl.text = settings.dbLimitMb.toString();
          _initialized = true;
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.settings),
            actions: const [
              CommonAppBarActions(showSettingsButton: false),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.settingsAiProvider,
                    style: Theme.of(context).textTheme.titleMedium),
                RadioListTile<AiProvider>(
                  title: Text(l10n.providerGemini),
                  value: AiProvider.gemini,
                  groupValue: _provider,
                  onChanged: (v) => setState(() => _provider = v!),
                ),
                RadioListTile<AiProvider>(
                  title: Text(l10n.providerClaude),
                  value: AiProvider.claude,
                  groupValue: _provider,
                  onChanged: (v) => setState(() => _provider = v!),
                ),
                const SizedBox(height: 16),
                Text('Google Gemini API キー',
                    style: Theme.of(context).textTheme.titleMedium),
                TextField(
                  controller: _googleKeyCtrl,
                  obscureText: _obscureGoogle,
                  decoration: InputDecoration(
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
                TextField(
                  controller: _claudeKeyCtrl,
                  obscureText: _obscureClaude,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(_obscureClaude
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _obscureClaude = !_obscureClaude),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.settingsQuizCount,
                    style: Theme.of(context).textTheme.titleMedium),
                TextField(
                  controller: _quizCountCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Text(l10n.settingsDbLimit,
                    style: Theme.of(context).textTheme.titleMedium),
                TextField(
                  controller: _dbLimitCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Text('読み上げアクセント',
                    style: Theme.of(context).textTheme.titleMedium),
                RadioListTile<TtsAccent>(
                  title: const Text('アメリカ英語 (US)'),
                  value: TtsAccent.american,
                  groupValue: _ttsAccent,
                  onChanged: (v) => setState(() => _ttsAccent = v!),
                ),
                RadioListTile<TtsAccent>(
                  title: const Text('イギリス英語 (UK)'),
                  value: TtsAccent.british,
                  groupValue: _ttsAccent,
                  onChanged: (v) => setState(() => _ttsAccent = v!),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _save,
                  child: Text(l10n.save),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 8),
                Text(l10n.exportImport,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.import_export),
                  title: Text(l10n.exportImport),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/export'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    final settings = AppSettings(
      aiProvider: _provider,
      googleApiKey: _googleKeyCtrl.text.isEmpty ? null : _googleKeyCtrl.text,
      claudeApiKey: _claudeKeyCtrl.text.isEmpty ? null : _claudeKeyCtrl.text,
      quizCount: int.tryParse(_quizCountCtrl.text) ?? 20,
      dbLimitMb: int.tryParse(_dbLimitCtrl.text) ?? 100,
      ttsAccent: _ttsAccent,
    );
    await ref.read(settingsProvider.notifier).save(settings);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.save)),
      );
    }
  }
}
