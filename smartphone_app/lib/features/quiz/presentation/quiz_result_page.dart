import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:language_learn_app/l10n/app_localizations.dart';
import '../../../common/widgets/ad_scaffold.dart';
import '../../../common/widgets/common_app_bar_actions.dart';
import '../../../core/tts/tts_service.dart';
import '../../words/data/word_repository.dart';
import '../../words/domain/word.dart' as domain;
import '../data/quiz_repository.dart';

final _quizResultProvider =
    FutureProvider.family<_QuizResult, int>((ref, sessionId) async {
  final quizRepo = ref.watch(quizRepositoryProvider);
  final wordRepo = ref.watch(wordRepositoryProvider);
  final answers = await quizRepo.getAnswers(sessionId);
  final correctCount = answers.where((a) => a.isCorrect).length;
  final wrongWordIds =
      answers.where((a) => !a.isCorrect).map((a) => a.wordId).toList();
  final wrongWords = (await Future.wait(
          wrongWordIds.map((id) => wordRepo.getWordById(id))))
      .whereType<domain.Word>()
      .toList();
  return _QuizResult(
    total: answers.length,
    correctCount: correctCount,
    wrongWords: wrongWords,
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
  final List<domain.Word> wrongWords;

  double get rate => total == 0 ? 0 : correctCount / total;
}

class QuizResultPage extends ConsumerWidget {
  const QuizResultPage({super.key, required this.sessionId});

  final int sessionId;

  void _showWordDetail(BuildContext context, domain.Word word) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _WordDetailSheet(word: word),
    );
  }

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
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color:
                          result.rate >= 0.8 ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
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
                  child: ListView.separated(
                    itemCount: result.wrongWords.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final w = result.wrongWords[i];
                      return ListTile(
                        leading:
                            const Icon(Icons.close, color: Colors.red),
                        title: Text(w.word,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          w.meaning,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showWordDetail(context, w),
                      );
                    },
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

class _WordDetailSheet extends ConsumerWidget {
  const _WordDetailSheet({required this.word});

  final domain.Word word;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          // ドラッグハンドル
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          word.word,
                          style: theme.textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        tooltip: '読み上げ',
                        onPressed: () =>
                            ref.read(ttsServiceProvider).speak(word.word),
                      ),
                      IconButton(
                        icon: const Icon(Icons.open_in_new),
                        tooltip: '詳細を開く',
                        onPressed: () {
                          final router = GoRouter.of(context);
                          Navigator.of(context).pop();
                          router.push('/words/${word.id}');
                        },
                      ),
                    ],
                  ),
                  if (word.reading != null) ...[
                    Text(word.reading!,
                        style: theme.textTheme.bodySmall),
                    const SizedBox(height: 4),
                  ],
                  if (word.partOfSpeech != null) ...[
                    Chip(label: Text(word.partOfSpeech!)),
                    const SizedBox(height: 4),
                  ],
                  const SizedBox(height: 8),
                  Text(word.meaning, style: theme.textTheme.bodyLarge),
                  if (word.exampleSentences.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('例文', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    ...word.exampleSentences.map((s) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(s.sentenceEn,
                                          style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.w500)),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.volume_up,
                                          size: 20),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () => ref
                                          .read(ttsServiceProvider)
                                          .speak(s.sentenceEn),
                                    ),
                                  ],
                                ),
                                Text(s.sentenceJa,
                                    style: const TextStyle(
                                        color: Colors.grey)),
                              ],
                            ),
                          ),
                        )),
                  ],
                  if (word.sources.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('出典', style: theme.textTheme.titleMedium),
                    ...word.sources.map((src) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.book_outlined),
                          title: Text(src.title ?? src.sourceType.name),
                          subtitle:
                              src.url != null ? Text(src.url!) : null,
                        )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
