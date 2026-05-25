import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:language_learn_app/l10n/app_localizations.dart';
import '../../../common/widgets/common_app_bar_actions.dart';
import '../../../core/tts/tts_service.dart';
import '../data/word_repository.dart';

final _wordDetailProvider = FutureProvider.family((ref, int id) {
  return ref.watch(wordRepositoryProvider).getWordById(id);
});

class WordDetailPage extends ConsumerWidget {
  const WordDetailPage({super.key, required this.wordId});

  final int wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final wordAsync = ref.watch(_wordDetailProvider(wordId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wordDetail),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/words/$wordId/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, ref, l10n),
          ),
          const CommonAppBarActions(),
        ],
      ),
      body: wordAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (word) {
          if (word == null) return const SizedBox();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(word.word,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up),
                      onPressed: () =>
                          ref.read(ttsServiceProvider).speak(word.word),
                    ),
                  ],
                ),
                if (word.reading != null)
                  Text(word.reading!,
                      style: Theme.of(context).textTheme.bodySmall),
                if (word.partOfSpeech != null)
                  Chip(label: Text(word.partOfSpeech!)),
                const SizedBox(height: 12),
                Text(word.meaning,
                    style: Theme.of(context).textTheme.bodyLarge),
                if (word.exampleSentences.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(l10n.exampleSentence,
                      style: Theme.of(context).textTheme.titleMedium),
                  ...word.exampleSentences.map((s) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(s.sentenceEn,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.volume_up, size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => ref
                                        .read(ttsServiceProvider)
                                        .speak(s.sentenceEn),
                                  ),
                                ],
                              ),
                              Text(s.sentenceJa,
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      )),
                ],
                if (word.sources.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(l10n.wordSource,
                      style: Theme.of(context).textTheme.titleMedium),
                  ...word.sources.map((src) => ListTile(
                        leading: const Icon(Icons.book),
                        title: Text(src.title ?? src.sourceType.name),
                        subtitle:
                            src.url != null ? Text(src.url!) : null,
                      )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteWord),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.delete,
                  style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(wordRepositoryProvider).deleteWord(wordId);
      context.pop();
    }
  }
}
