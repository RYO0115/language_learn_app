import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

part 'quiz_dao.g.dart';

@DriftAccessor(tables: [Words, QuizSessions, QuizAnswers])
class QuizDao extends DatabaseAccessor<AppDatabase> with _$QuizDaoMixin {
  QuizDao(super.db);

  Future<int> createSession(int startedAt) =>
      into(quizSessions).insert(QuizSessionsCompanion.insert(
        startedAt: startedAt,
      ));

  Future<void> completeSession(int sessionId, int completedAt) =>
      (update(quizSessions)..where((s) => s.id.equals(sessionId))).write(
        QuizSessionsCompanion(completedAt: Value(completedAt)),
      );

  Future<int> insertAnswer(QuizAnswersCompanion answer) =>
      into(quizAnswers).insert(answer);

  Future<List<QuizAnswer>> getAnswersBySession(int sessionId) =>
      (select(quizAnswers)
            ..where((a) => a.sessionId.equals(sessionId)))
          .get();

  // 未テスト単語（一度も回答していない）を優先取得
  Future<List<Word>> getUnansweredWords() async {
    final answeredWordIds = await (selectOnly(quizAnswers)
          ..addColumns([quizAnswers.wordId]))
        .map((r) => r.read(quizAnswers.wordId)!)
        .get();
    return (select(words)
          ..where((w) => w.id.isNotIn(answeredWordIds)))
        .get();
  }

  // 各単語の正答率を取得（低い順）
  Future<List<Word>> getWordsByCorrectRateAsc() async {
    final allWords = await select(words).get();
    final rates = <int, double>{};
    for (final w in allWords) {
      final answers = await (select(quizAnswers)
            ..where((a) => a.wordId.equals(w.id)))
          .get();
      if (answers.isEmpty) continue;
      rates[w.id] =
          answers.where((a) => a.isCorrect == 1).length / answers.length;
    }
    final sorted = allWords
        .where((w) => rates.containsKey(w.id))
        .toList()
      ..sort((a, b) => rates[a.id]!.compareTo(rates[b.id]!));
    return sorted;
  }

  Future<QuizSession?> getSession(int id) =>
      (select(quizSessions)..where((s) => s.id.equals(id)))
          .getSingleOrNull();
}
