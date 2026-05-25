import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/presentation/settings_provider.dart';
import 'ad_banner_widget.dart';

/// 各画面の Scaffold をラップし、広告が有効な場合のみ
/// AppBar 直下と画面下端にバナー広告を追加する。
class AdScaffold extends ConsumerWidget {
  const AdScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adsEnabled =
        ref.watch(settingsProvider).valueOrNull?.adsEnabled ?? true;

    if (!adsEnabled) {
      return Scaffold(
        appBar: appBar,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        floatingActionButton: floatingActionButton,
        body: body,
      );
    }

    return Scaffold(
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          const AdBannerWidget(),
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
