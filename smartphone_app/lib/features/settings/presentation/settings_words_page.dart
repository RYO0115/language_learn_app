import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_learn_app/l10n/app_localizations.dart';
import '../../../common/widgets/common_app_bar_actions.dart';
import '../../export/data/export_service.dart';
import '../domain/app_settings.dart';
import 'settings_provider.dart';

class SettingsWordsPage extends ConsumerStatefulWidget {
  const SettingsWordsPage({super.key});

  @override
  ConsumerState<SettingsWordsPage> createState() => _SettingsWordsPageState();
}

class _SettingsWordsPageState extends ConsumerState<SettingsWordsPage> {
  final _dbLimitCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _dbLimitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(settingsProvider);
    final service = ref.watch(exportServiceProvider);

    return settingsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (settings) {
        if (!_initialized) {
          _dbLimitCtrl.text = settings.dbLimitMb.toString();
          _initialized = true;
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('単語帳設定'),
            actions: const [CommonAppBarActions(showSettingsButton: false)],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.settingsDbLimit,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _dbLimitCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    suffixText: 'MB',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _save,
                  child: Text(l10n.save),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 8),
                const Text('単語帳のエクスポート/インポート',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text('エクスポート',
                    style: Theme.of(context).textTheme.titleSmall),
                _ActionTile(
                  icon: Icons.download,
                  title: l10n.exportJson,
                  onTap: () => _run(context, service.exportJson),
                ),
                _ActionTile(
                  icon: Icons.download,
                  title: l10n.exportCsv,
                  onTap: () => _run(context, service.exportCsv),
                ),
                const Divider(height: 24),
                Text('インポート',
                    style: Theme.of(context).textTheme.titleSmall),
                _ActionTile(
                  icon: Icons.upload,
                  title: l10n.importJson,
                  onTap: () => _import(context, service, 'json'),
                ),
                _ActionTile(
                  icon: Icons.upload,
                  title: l10n.importCsv,
                  onTap: () => _import(context, service, 'csv'),
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
      quizCount: current.quizCount,
      dbLimitMb: int.tryParse(_dbLimitCtrl.text) ?? 100,
      ttsAccent: current.ttsAccent,
    );
    await ref.read(settingsProvider.notifier).save(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.save)),
      );
    }
  }

  Future<void> _run(
      BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _import(
      BuildContext context, ExportService service, String ext) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [ext],
    );
    if (result == null || result.files.single.path == null) return;
    final content = await File(result.files.single.path!).readAsString();
    try {
      final count = ext == 'json'
          ? await service.importJson(content)
          : await service.importCsv(content);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)!.duplicateSkipped}: $count 件インポート')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile(
      {required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
