import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/word_repository.dart';
import '../domain/word.dart';

final wordListProvider = StreamProvider<List<Word>>((ref) {
  final repo = ref.watch(wordRepositoryProvider);
  return repo.watchAllWords();
});

final wordCountProvider = FutureProvider<int>((ref) {
  final repo = ref.watch(wordRepositoryProvider);
  ref.watch(wordListProvider); // invalidate when list changes
  return repo.countWords();
});

final wordSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredWordListProvider = Provider<AsyncValue<List<Word>>>((ref) {
  final query = ref.watch(wordSearchQueryProvider).toLowerCase();
  final words = ref.watch(wordListProvider);
  if (query.isEmpty) return words;
  return words.whenData(
    (list) => list
        .where((w) =>
            w.word.toLowerCase().contains(query) ||
            w.meaning.toLowerCase().contains(query))
        .toList(),
  );
});
