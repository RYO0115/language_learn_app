import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../streak/presentation/streak_provider.dart';
import '../../words/data/word_repository.dart';

class DashboardData {
  const DashboardData({
    required this.wordCount,
    required this.currentStreak,
  });

  final int wordCount;
  final int currentStreak;
}

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final wordCount = await ref.watch(wordRepositoryProvider).countWords();
  final streak = ref.watch(currentStreakProvider);
  return DashboardData(wordCount: wordCount, currentStreak: streak);
});
