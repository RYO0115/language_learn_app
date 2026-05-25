import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_learn_app/l10n/app_localizations.dart';
import '../../../common/widgets/common_app_bar_actions.dart';
import '../data/export_service.dart';

class ExportPage extends ConsumerWidget {
  const ExportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final service = ref.watch(exportServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.exportImport),
        actions: const [CommonAppBarActions()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('エクスポート',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
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
          const Divider(height: 32),
          Text('インポート',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
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
    );
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
    final content =
        await File(result.files.single.path!).readAsString();
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
