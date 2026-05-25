import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../streak/presentation/streak_provider.dart';
import '../../words/presentation/word_list_provider.dart';

class DashboardData {
  const DashboardData({
    required this.wordCount,
    required this.currentStreak,
  });

  final int wordCount;
  final int currentStreak;
}

final dashboardProvider = Provider<AsyncValue<DashboardData>>((ref) {
  final wordListAsync = ref.watch(wordListProvider);
  final streak = ref.watch(currentStreakProvider);
  return wordListAsync.whenData(
    (words) => DashboardData(wordCount: words.length, currentStreak: streak),
  );
});
