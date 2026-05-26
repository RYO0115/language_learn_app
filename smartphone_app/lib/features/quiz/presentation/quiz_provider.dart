import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_utils.dart';
import '../../settings/presentation/settings_provider.dart';
import '../../streak/data/streak_repository.dart';
import '../../words/data/word_repository.dart';
import '../../words/domain/source_filter.dart';
import '../../words/domain/word.dart';
import '../data/quiz_repository.dart';

// クイズ開始前に出典フィルタをセットしてから /quiz に遷移する
final quizSourceFilterProvider =
    StateProvider<SourceFilter?>((ref) => null);

enum QuizPhase { loading, question, revealing, completed }

class QuizState {
  const QuizState({
    this.phase = QuizPhase.loading,
    this.sessionId,
    this.queue = const [],
    this.currentIndex = 0,
    this.correctCount = 0,
  });

  final QuizPhase phase;
  final int? sessionId;
  final List<Word> queue;
  final int currentIndex;
  final int correctCount;

  Word? get currentWord =>
      currentIndex < queue.length ? queue[currentIndex] : null;

  bool get hasNext => currentIndex + 1 < queue.length;

  double get correctRate =>
      queue.isEmpty ? 0 : correctCount / queue.length;

  QuizState copyWith({
    QuizPhase? phase,
    int? sessionId,
    List<Word>? queue,
    int? currentIndex,
    int? correctCount,
  }) {
    return QuizState(
      phase: phase ?? this.phase,
      sessionId: sessionId ?? this.sessionId,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      correctCount: correctCount ?? this.correctCount,
    );
  }
}

final quizProvider =
    StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier(ref);
});

class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier(this._ref) : super(const QuizState());

  final Ref _ref;

  Future<void> startQuiz() async {
    state = const QuizState(phase: QuizPhase.loading);
    final repo = _ref.read(quizRepositoryProvider);
    final settings = await _ref.read(settingsProvider.future);

    // 出典フィルタが設定されていれば対象 ID を絞り込む
    final sourceFilter = _ref.read(quizSourceFilterProvider);
    _ref.read(quizSourceFilterProvider.notifier).state = null;

    Set<int>? allowedWordIds;
    if (sourceFilter != null && !sourceFilter.isEmpty) {
      final allWords =
          await _ref.read(wordRepositoryProvider).getAllWords();
      allowedWordIds = allWords
          .where(sourceFilter.matchesWord)
          .map((w) => w.id)
          .toSet();
    }

    final queue = await repo.buildQuizQueue(
      settings.quizCount,
      allowedWordIds: allowedWordIds,
    );
    final sessionId = await repo.startSession();
    state = QuizState(
      phase: QuizPhase.question,
      sessionId: sessionId,
      queue: queue,
    );
  }

  void revealAnswer() {
    state = state.copyWith(phase: QuizPhase.revealing);
  }

  Future<void> answer(bool isCorrect) async {
    final word = state.currentWord;
    final sessionId = state.sessionId;
    if (word == null || sessionId == null) return;

    final repo = _ref.read(quizRepositoryProvider);
    await repo.recordAnswer(
      sessionId: sessionId,
      wordId: word.id,
      isCorrect: isCorrect,
    );

    final newCorrect = state.correctCount + (isCorrect ? 1 : 0);

    if (state.hasNext) {
      state = state.copyWith(
        phase: QuizPhase.question,
        currentIndex: state.currentIndex + 1,
        correctCount: newCorrect,
      );
    } else {
      await repo.completeSession(sessionId);
      final today = DateTime.now().toDateString();
      await _ref.read(streakRepositoryProvider).recordQuizComplete(today);
      state = state.copyWith(
        phase: QuizPhase.completed,
        correctCount: newCorrect,
      );
    }
  }
}
