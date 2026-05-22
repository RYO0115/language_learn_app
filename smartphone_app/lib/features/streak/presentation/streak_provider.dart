import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/streak_repository.dart';
import '../domain/study_record.dart';

final streakProvider = FutureProvider<List<StudyRecord>>((ref) {
  return ref.watch(streakRepositoryProvider).getAllRecords();
});

final currentStreakProvider = Provider<int>((ref) {
  final records = ref.watch(streakProvider);
  final repo = ref.watch(streakRepositoryProvider);
  return records.whenOrNull(data: (r) => repo.calculateCurrentStreak(r)) ?? 0;
});
