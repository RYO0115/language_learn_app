import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/date_utils.dart';
import '../../words/data/word_repository.dart';
import '../domain/study_record.dart' as model;
import 'streak_dao.dart';

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return StreakRepository(StreakDao(db));
});

class StreakRepository {
  StreakRepository(this._dao);

  final StreakDao _dao;

  Future<List<model.StudyRecord>> getAllRecords() async {
    final rows = await _dao.getAllRecords();
    return rows
        .map((r) => model.StudyRecord(
              id: r.id,
              studyDate: r.studyDate,
              wordsStudied: r.wordsStudied,
              quizCompleted: r.quizCompleted,
            ))
        .toList();
  }

  Future<void> recordQuizComplete(String date) async {
    final existing = await _dao.getRecordByDate(date);
    await _dao.upsertRecord(StudyRecordsCompanion(
      id: existing != null ? Value(existing.id) : const Value.absent(),
      studyDate: Value(date),
      quizCompleted: Value((existing?.quizCompleted ?? 0) + 1),
      wordsStudied: Value(existing?.wordsStudied ?? 0),
    ));
  }

  Future<void> recordWordAdded(String date) async {
    final existing = await _dao.getRecordByDate(date);
    await _dao.upsertRecord(StudyRecordsCompanion(
      id: existing != null ? Value(existing.id) : const Value.absent(),
      studyDate: Value(date),
      wordsStudied: Value((existing?.wordsStudied ?? 0) + 1),
      quizCompleted: Value(existing?.quizCompleted ?? 0),
    ));
  }

  int calculateCurrentStreak(List<model.StudyRecord> records) {
    if (records.isEmpty) return 0;
    final dates = records.map((r) => r.studyDate).toSet();
    var streak = 0;
    var day = DateTime.now();
    while (dates.contains(day.toDateString())) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
