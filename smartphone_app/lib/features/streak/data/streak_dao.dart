import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

part 'streak_dao.g.dart';

@DriftAccessor(tables: [StudyRecords])
class StreakDao extends DatabaseAccessor<AppDatabase> with _$StreakDaoMixin {
  StreakDao(super.db);

  Future<List<StudyRecord>> getAllRecords() =>
      (select(studyRecords)
            ..orderBy([(r) => OrderingTerm.desc(r.studyDate)]))
          .get();

  Future<StudyRecord?> getRecordByDate(String date) =>
      (select(studyRecords)
            ..where((r) => r.studyDate.equals(date)))
          .getSingleOrNull();

  Future<void> upsertRecord(StudyRecordsCompanion record) =>
      into(studyRecords).insertOnConflictUpdate(record);
}
