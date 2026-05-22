import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Words extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get word => text().withLength(max: 100).unique()();
  TextColumn get reading => text().nullable()();
  TextColumn get meaning => text()();
  TextColumn get partOfSpeech => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
}

class ExampleSentences extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get wordId =>
      integer().references(Words, #id, onDelete: KeyAction.cascade)();
  TextColumn get sentenceEn => text()();
  TextColumn get sentenceJa => text()();
  IntColumn get order => integer().withDefault(const Constant(0))();
  TextColumn get label => text().nullable()();
}

class WordSources extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get wordId =>
      integer().references(Words, #id, onDelete: KeyAction.cascade)();
  TextColumn get sourceType => text()(); // book / website / video / other
  TextColumn get title => text().nullable()();
  TextColumn get url => text().nullable()();
  TextColumn get pageNumber => text().nullable()();
  TextColumn get detail => text().nullable()();
  IntColumn get createdAt => integer()();
}

class QuizSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get startedAt => integer()();
  IntColumn get completedAt => integer().nullable()();
}

class QuizAnswers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(QuizSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get wordId =>
      integer().references(Words, #id, onDelete: KeyAction.cascade)();
  IntColumn get isCorrect => integer()(); // 1=正解 / 0=不正解
  IntColumn get answeredAt => integer()();
}

class StudyRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get studyDate => text().unique()(); // YYYY-MM-DD
  IntColumn get wordsStudied => integer().withDefault(const Constant(0))();
  IntColumn get quizCompleted => integer().withDefault(const Constant(0))();
}

@DriftDatabase(
  tables: [
    Words,
    ExampleSentences,
    WordSources,
    QuizSessions,
    QuizAnswers,
    StudyRecords,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'language_learn.db'));
    return NativeDatabase.createInBackground(file);
  });
}
