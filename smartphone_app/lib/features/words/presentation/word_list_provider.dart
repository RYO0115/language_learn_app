import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/word_repository.dart';
import '../domain/source_filter.dart';
import '../domain/word.dart';
import '../domain/word_source.dart';

final wordListProvider = StreamProvider<List<Word>>((ref) {
  final repo = ref.watch(wordRepositoryProvider);
  return repo.watchAllWords();
});

final wordSearchQueryProvider = StateProvider<String>((ref) => '');

final sourceFilterProvider =
    StateProvider<SourceFilter>((ref) => const SourceFilter());

// 登録済みタイトル一覧（type=null なら全種別、指定すれば絞り込み）
final distinctSourceTitlesProvider =
    Provider.family<List<String>, SourceType?>((ref, type) {
  final words = ref.watch(wordListProvider).valueOrNull ?? [];
  final titles = <String>{};
  for (final w in words) {
    for (final s in w.sources) {
      if ((type == null || s.sourceType == type) &&
          s.title != null &&
          s.title!.isNotEmpty) {
        titles.add(s.title!);
      }
    }
  }
  return titles.toList()..sort();
});

final filteredWordListProvider = Provider<AsyncValue<List<Word>>>((ref) {
  final query = ref.watch(wordSearchQueryProvider).toLowerCase();
  final filter = ref.watch(sourceFilterProvider);
  final words = ref.watch(wordListProvider);

  return words.whenData((list) => list.where((w) {
        final matchesQuery = query.isEmpty ||
            w.word.toLowerCase().contains(query) ||
            w.meaning.toLowerCase().contains(query);
        return matchesQuery && filter.matchesWord(w);
      }).toList());
});

final wordCountProvider = FutureProvider<int>((ref) {
  final repo = ref.watch(wordRepositoryProvider);
  ref.watch(wordListProvider);
  return repo.countWords();
});
