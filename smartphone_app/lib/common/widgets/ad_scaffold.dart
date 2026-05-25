import 'package:flutter/material.dart';
import 'ad_banner_widget.dart';

/// 各画面の Scaffold をラップし、AppBar 直下と画面下端にバナー広告を追加する。
class AdScaffold extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
