import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'word_list_provider.dart';

class WordListPage extends ConsumerWidget {
  const WordListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final wordsAsync = ref.watch(filteredWordListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wordList),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.searchWords,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) =>
                  ref.read(wordSearchQueryProvider.notifier).state = v,
            ),
          ),
        ),
      ),
      body: wordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (words) {
          if (words.isEmpty) {
            return Center(child: Text(l10n.noWordsYet));
          }
          return ListView.separated(
            itemCount: words.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final w = words[i];
              return ListTile(
                title: Text(w.word,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(w.meaning, maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/words/${w.id}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/words/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
