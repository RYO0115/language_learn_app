import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:language_learn_app/l10n/app_localizations.dart';
import '../../../common/widgets/ad_scaffold.dart';
import '../../../common/widgets/common_app_bar_actions.dart';
import '../data/quiz_repository.dart';
import '../../words/data/word_repository.dart';

final _quizResultProvider =
    FutureProvider.family<_QuizResult, int>((ref, sessionId) async {
  final quizRepo = ref.watch(quizRepositoryProvider);
  final wordRepo = ref.watch(wordRepositoryProvider);
  final answers = await quizRepo.getAnswers(sessionId);
  final correctCount = answers.where((a) => a.isCorrect).length;
  final wrongWordIds =
      answers.where((a) => !a.isCorrect).map((a) => a.wordId).toList();
  final wrongWords = await Future.wait(
      wrongWordIds.map((id) => wordRepo.getWordById(id)));
  return _QuizResult(
    total: answers.length,
    correctCount: correctCount,
    wrongWords: wrongWords.whereType<dynamic>().map((w) => w.word as String).toList(),
  );
});

class _QuizResult {
  const _QuizResult({
    required this.total,
    required this.correctCount,
    required this.wrongWords,
  });

  final int total;
  final int correctCount;
  final List<String> wrongWords;

  double get rate => total == 0 ? 0 : correctCount / total;
}

class QuizResultPage extends ConsumerWidget {
  const QuizResultPage({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final resultAsync = ref.watch(_quizResultProvider(sessionId));

    return AdScaffold(
      appBar: AppBar(
        title: Text(l10n.quizResult),
        actions: const [CommonAppBarActions()],
      ),
      body: resultAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (result) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Text(
                l10n.sessionCompleted,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Text(
                '${(result.rate * 100).toStringAsFixed(0)}%',
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(
                        color: result.rate >= 0.8
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${result.correctCount} / ${result.total}',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (result.wrongWords.isNotEmpty) ...[
                Text(
                  '不正解の単語',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: result.wrongWords.length,
                    itemBuilder: (_, i) => ListTile(
                      leading: const Icon(Icons.close, color: Colors.red),
                      title: Text(result.wrongWords[i]),
                    ),
                  ),
                ),
              ] else
                const Spacer(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('ホームへ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
