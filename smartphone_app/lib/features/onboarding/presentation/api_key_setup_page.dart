import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:language_learn_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/widgets/ad_scaffold.dart';
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
    return AdScaffold(
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
    await ref.read(settingsProvider.notifier).save(settings);
    if (mounted) context.go('/');
  }
}

class _GuideSection extends StatefulWidget {
  const _GuideSection({required this.provider});

  final AiProvider provider;

  @override
  State<_GuideSection> createState() => _GuideSectionState();
}

class _GuideSectionState extends State<_GuideSection> {
  late final TapGestureRecognizer _tapRecognizer;

  static const _geminiUrl = 'https://aistudio.google.com/apikey';
  static const _claudeUrl = 'https://console.anthropic.com';

  String get _url =>
      widget.provider == AiProvider.gemini ? _geminiUrl : _claudeUrl;

  String get _urlDisplay => widget.provider == AiProvider.gemini
      ? 'aistudio.google.com/apikey'
      : 'console.anthropic.com';

  @override
  void initState() {
    super.initState();
    _tapRecognizer = TapGestureRecognizer()..onTap = _openUrl;
  }

  @override
  void dispose() {
    _tapRecognizer.dispose();
    super.dispose();
  }

  Future<void> _openUrl() async {
    final uri = Uri.parse(_url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildGuide(BuildContext context, String guide) {
    final idx = guide.indexOf(_urlDisplay);
    if (idx == -1) return Text(guide);

    final linkColor = Theme.of(context).colorScheme.primary;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: guide.substring(0, idx)),
          TextSpan(
            text: _urlDisplay,
            style: TextStyle(
              color: linkColor,
              decoration: TextDecoration.underline,
              decorationColor: linkColor,
            ),
            recognizer: _tapRecognizer,
          ),
          TextSpan(text: guide.substring(idx + _urlDisplay.length)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isGemini = widget.provider == AiProvider.gemini;
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
          Text(
            isGemini
                ? '【Google Gemini（無料・カード不要）】'
                : '【Anthropic Claude（有料プラン必要）】',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          _buildGuide(context, isGemini ? l10n.geminiGuide : l10n.claudeGuide),
        ],
      ),
    );
  }
}
