import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart' hide Word, QuizSession, QuizAnswer;
import '../../../core/utils/date_utils.dart';
import '../../words/data/word_repository.dart';
import '../../words/domain/word.dart';
import '../domain/quiz_answer.dart';
import '../domain/quiz_session.dart';
import 'quiz_dao.dart';

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return QuizRepository(QuizDao(db));
});

class QuizRepository {
  QuizRepository(this._dao);

  final QuizDao _dao;

  Future<List<Word>> buildQuizQueue(int count) async {
    final unanswered = await _dao.getUnansweredWords();
    final lowRate = await _dao.getWordsByCorrectRateAsc();
    final seen = <int>{};
    final queue = <Word>[];

    for (final w in [...unanswered, ...lowRate]) {
      if (seen.contains(w.id)) continue;
      seen.add(w.id);
      queue.add(Word(
        id: w.id,
        word: w.word,
        reading: w.reading,
        meaning: w.meaning,
        partOfSpeech: w.partOfSpeech,
        createdAt: w.createdAt.toDateTime(),
        updatedAt: w.updatedAt.toDateTime(),
      ));
      if (queue.length >= count) break;
    }
    return queue;
  }

  Future<int> startSession() async {
    final now = DateTime.now().toUnixTimestamp();
    return _dao.createSession(now);
  }

  Future<void> recordAnswer({
    required int sessionId,
    required int wordId,
    required bool isCorrect,
  }) async {
    final now = DateTime.now().toUnixTimestamp();
    await _dao.insertAnswer(QuizAnswersCompanion.insert(
      sessionId: sessionId,
      wordId: wordId,
      isCorrect: isCorrect ? 1 : 0,
      answeredAt: now,
    ));
  }

  Future<QuizSession> completeSession(int sessionId) async {
    final now = DateTime.now().toUnixTimestamp();
    await _dao.completeSession(sessionId, now);
    final row = await _dao.getSession(sessionId);
    return QuizSession(
      id: row!.id,
      startedAt: row.startedAt.toDateTime(),
      completedAt: row.completedAt?.toDateTime(),
    );
  }

  Future<List<QuizAnswer>> getAnswers(int sessionId) async {
    final rows = await _dao.getAnswersBySession(sessionId);
    return rows
        .map((a) => QuizAnswer(
              id: a.id,
              sessionId: a.sessionId,
              wordId: a.wordId,
              isCorrect: a.isCorrect == 1,
              answeredAt: a.answeredAt.toDateTime(),
            ))
        .toList();
  }
}
