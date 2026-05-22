import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../core/utils/date_utils.dart';
import 'streak_provider.dart';

class StreakCalendarPage extends ConsumerWidget {
  const StreakCalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final recordsAsync = ref.watch(streakProvider);
    final streak = ref.watch(currentStreakProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.streak)),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (records) {
          final studyDates = records.map((r) => r.studyDate).toSet();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _StreakBadge(streak: streak, l10n: l10n),
                const SizedBox(height: 24),
                _CalendarView(studyDates: studyDates),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak, required this.l10n});

  final int streak;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_fire_department,
                color: Colors.orange, size: 40),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.currentStreak,
                    style: Theme.of(context).textTheme.bodySmall),
                Text('$streak 日',
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarView extends StatelessWidget {
  const _CalendarView({required this.studyDates});

  final Set<String> studyDates;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final daysInMonth =
        DateTime(now.year, now.month + 1, 0).day;

    return Column(
      children: [
        Text('${now.year}年${now.month}月',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: daysInMonth + firstDay.weekday - 1,
          itemBuilder: (_, i) {
            if (i < firstDay.weekday - 1) return const SizedBox();
            final day = i - firstDay.weekday + 2;
            final date =
                DateTime(now.year, now.month, day).toDateString();
            final hasStudy = studyDates.contains(date);
            return Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: hasStudy ? Colors.green : null,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: hasStudy ? Colors.white : null,
                    fontWeight: hasStudy ? FontWeight.bold : null,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
