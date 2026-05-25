import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/settings/domain/app_settings.dart';
import '../../features/settings/presentation/settings_provider.dart';

class CommonAppBarActions extends ConsumerWidget {
  const CommonAppBarActions({super.key, this.showSettingsButton = true});

  final bool showSettingsButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent =
        ref.watch(settingsProvider).valueOrNull?.ttsAccent ?? TtsAccent.american;
    final foreground = IconTheme.of(context).color ?? Colors.white;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () {
            final settings = ref.read(settingsProvider).valueOrNull;
            if (settings == null) return;
            final next = accent == TtsAccent.american
                ? TtsAccent.british
                : TtsAccent.american;
            ref
                .read(settingsProvider.notifier)
                .save(settings.copyWith(ttsAccent: next));
          },
          style: TextButton.styleFrom(
            foregroundColor: foreground,
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          child: Text(
            accent == TtsAccent.british ? 'UK' : 'US',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        if (showSettingsButton)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
      ],
    );
  }
}
