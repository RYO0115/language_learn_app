import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:language_learn_app/features/streak/data/streak_dao.dart';
import 'package:language_learn_app/features/streak/data/streak_repository.dart';
import 'package:language_learn_app/features/streak/domain/study_record.dart';

class MockStreakDao extends Mock implements StreakDao {}

void main() {
  late MockStreakDao mockDao;
  late StreakRepository repo;

  setUp(() {
    mockDao = MockStreakDao();
    repo = StreakRepository(mockDao);
  });

  group('StreakRepository', () {
    test('T-S-02: calculates streak correctly for consecutive days', () {
      final now = DateTime.now();
      final records = [
        StudyRecord(
          id: 1,
          studyDate: _dateStr(now),
          wordsStudied: 5,
          quizCompleted: 1,
        ),
        StudyRecord(
          id: 2,
          studyDate: _dateStr(now.subtract(const Duration(days: 1))),
          wordsStudied: 3,
          quizCompleted: 1,
        ),
        StudyRecord(
          id: 3,
          studyDate: _dateStr(now.subtract(const Duration(days: 2))),
          wordsStudied: 4,
          quizCompleted: 1,
        ),
      ];

      final streak = repo.calculateCurrentStreak(records);
      expect(streak, 3);
    });

    test('T-S-02: streak breaks on missing day', () {
      final now = DateTime.now();
      final records = [
        StudyRecord(
          id: 1,
          studyDate: _dateStr(now),
          wordsStudied: 5,
          quizCompleted: 1,
        ),
        StudyRecord(
          id: 2,
          studyDate: _dateStr(now.subtract(const Duration(days: 2))),
          wordsStudied: 3,
          quizCompleted: 1,
        ),
      ];

      final streak = repo.calculateCurrentStreak(records);
      expect(streak, 1);
    });
  });
}

String _dateStr(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
