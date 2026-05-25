import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:language_learn_app/l10n/app_localizations.dart';
import '../../../common/widgets/ad_scaffold.dart';
import '../../../common/widgets/common_app_bar_actions.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return AdScaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        actions: const [CommonAppBarActions(showSettingsButton: false)],
      ),
      body: ListView(
        children: [
          _SettingsTile(
            icon: Icons.smart_toy_outlined,
            title: 'AI 設定',
            subtitle: 'AIプロバイダー・APIキー',
            onTap: () => context.push('/settings/ai'),
          ),
          const Divider(height: 1),
          _SettingsTile(
            icon: Icons.quiz_outlined,
            title: 'クイズ設定',
            subtitle: '出題数などの設定',
            onTap: () => context.push('/settings/quiz'),
          ),
          const Divider(height: 1),
          _SettingsTile(
            icon: Icons.menu_book_outlined,
            title: '単語帳設定',
            subtitle: '容量制限・エクスポート',
            onTap: () => context.push('/settings/words'),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
    );
  }
}
