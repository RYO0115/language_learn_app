import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:language_learn_app/l10n/app_localizations.dart';
import '../../../common/widgets/ad_scaffold.dart';
import '../../../common/widgets/common_app_bar_actions.dart';
import '../../../core/ads/interstitial_ad_service.dart';
import 'quiz_provider.dart';

class QuizPage extends ConsumerStatefulWidget {
  const QuizPage({super.key});

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  final _interstitialAd = InterstitialAdService();
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _interstitialAd.load();
    Future.microtask(() => ref.read(quizProvider.notifier).startQuiz());
  }

  @override
  void dispose() {
    _interstitialAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final quiz = ref.watch(quizProvider);

    if (quiz.phase == QuizPhase.completed && !_hasNavigated) {
      _hasNavigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _interstitialAd.showIfReady(
          onDismissed: () {
            if (mounted) {
              context.pushReplacement('/quiz/result/${quiz.sessionId}');
            }
          },
        );
      });
    }

    return AdScaffold(
      appBar: AppBar(
        title: Text(quiz.queue.isEmpty
            ? l10n.quizStart
            : '${quiz.currentIndex + 1} / ${quiz.queue.length}'),
        actions: const [CommonAppBarActions()],
      ),
      body: switch (quiz.phase) {
        QuizPhase.loading =>
          const Center(child: CircularProgressIndicator()),
        QuizPhase.question => _QuestionView(
            word: quiz.currentWord!.word,
            onReveal: () =>
                ref.read(quizProvider.notifier).revealAnswer(),
          ),
        QuizPhase.revealing => _RevealView(
            word: quiz.currentWord!.word,
            meaning: quiz.currentWord!.meaning,
            reading: quiz.currentWord!.reading,
            onAnswer: (correct) =>
                ref.read(quizProvider.notifier).answer(correct),
            l10n: l10n,
          ),
        QuizPhase.completed => const Center(
            child: CircularProgressIndicator(),
          ),
      },
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({required this.word, required this.onReveal});

  final String word;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(word,
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: onReveal,
            child: const Text('答えを見る'),
          ),
        ],
      ),
    );
  }
}

class _RevealView extends StatelessWidget {
  const _RevealView({
    required this.word,
    required this.meaning,
    this.reading,
    required this.onAnswer,
    required this.l10n,
  });

  final String word;
  final String meaning;
  final String? reading;
  final void Function(bool) onAnswer;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(word,
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          if (reading != null)
            Text(reading!,
                style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          Text(meaning, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => onAnswer(false),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red),
                  child: Text(l10n.unknown),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => onAnswer(true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green),
                  child: Text(l10n.known),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
