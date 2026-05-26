import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:language_learn_app/l10n/app_localizations.dart';
import '../../../common/widgets/ad_scaffold.dart';
import '../../../common/widgets/common_app_bar_actions.dart';
import '../../../core/purchase/purchase_provider.dart';
import 'settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider).valueOrNull;
    final adsEnabled = settings?.adsEnabled ?? true;
    final isPremium = settings?.isPremium ?? false;
    final purchase = ref.watch(purchaseProvider);

    return AdScaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        actions: const [CommonAppBarActions(showSettingsButton: false)],
      ),
      body: ListView(
        children: [
          isPremium
              ? const ListTile(
                  leading: Icon(Icons.workspace_premium,
                      color: Colors.amber),
                  title: Text('プレミアム会員'),
                  subtitle: Text('単語登録数の上限が解除されています'),
                  trailing: Icon(Icons.check_circle, color: Colors.green),
                )
              : ListTile(
                  leading: const Icon(Icons.workspace_premium_outlined),
                  title: const Text('プレミアムにアップグレード'),
                  subtitle: Text(purchase.productDetails != null
                      ? '単語無制限登録 ${purchase.productDetails!.price}'
                      : '単語無制限登録（買い切り）'),
                  trailing: purchase.isPending
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: purchase.isPending || !purchase.isAvailable
                      ? null
                      : () => ref.read(purchaseProvider.notifier).buy(),
                ),
          if (!isPremium) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('購入を復元する'),
              subtitle: const Text('以前の購入を復元します'),
              trailing: purchase.isPending
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              onTap: purchase.isPending
                  ? null
                  : () => ref.read(purchaseProvider.notifier).restore(),
            ),
          ],
          const Divider(height: 1),
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
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.ad_units_outlined),
            title: const Text('広告を表示する'),
            subtitle: const Text('広告収益でアプリの開発を支援できます'),
            value: adsEnabled,
            onChanged: settings == null
                ? null
                : (v) async {
                    final updated = settings.copyWith(adsEnabled: v);
                    await ref
                        .read(settingsProvider.notifier)
                        .save(updated);
                  },
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
