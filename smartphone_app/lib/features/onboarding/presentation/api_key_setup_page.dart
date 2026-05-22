import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../settings/domain/app_settings.dart';
import '../../settings/presentation/settings_provider.dart';

class ApiKeySetupPage extends ConsumerStatefulWidget {
  const ApiKeySetupPage({super.key});

  @override
  ConsumerState<ApiKeySetupPage> createState() => _ApiKeySetupPageState();
}

class _ApiKeySetupPageState extends ConsumerState<ApiKeySetupPage> {
  AiProvider _provider = AiProvider.gemini;
  final _keyCtrl = TextEditingController();
  bool _obscure = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _keyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(l10n.onboardingTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center),
              Text(l10n.onboardingSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 32),
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
              Text(l10n.settingsApiKey,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _keyCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _GuideSection(provider: _provider),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving || _keyCtrl.text.isEmpty
                    ? null
                    : _save,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : Text(l10n.saveAndStart),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final key = _keyCtrl.text.trim();
    if (key.isEmpty) return;
    setState(() => _isSaving = true);
    final settings = AppSettings(
      aiProvider: _provider,
      googleApiKey: _provider == AiProvider.gemini ? key : null,
      claudeApiKey: _provider == AiProvider.claude ? key : null,
    );
    await ref.read(settingsProvider.notifier).update(settings);
    if (mounted) context.go('/');
  }
}

class _GuideSection extends StatelessWidget {
  const _GuideSection({required this.provider});

  final AiProvider provider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('── 取得方法 ──',
              style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
          if (provider == AiProvider.gemini) ...[
            Text('【Google Gemini（無料・カード不要）】',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(l10n.geminiGuide),
          ] else ...[
            Text('【Anthropic Claude（有料プラン必要）】',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(l10n.claudeGuide),
          ],
        ],
      ),
    );
  }
}
