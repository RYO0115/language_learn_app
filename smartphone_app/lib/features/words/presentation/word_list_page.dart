import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:language_learn_app/l10n/app_localizations.dart';
import '../../../common/widgets/common_app_bar_actions.dart';
import '../../../core/tts/tts_service.dart';
import 'word_list_provider.dart';

class WordListPage extends ConsumerStatefulWidget {
  const WordListPage({super.key});

  @override
  ConsumerState<WordListPage> createState() => _WordListPageState();
}

class _WordListPageState extends ConsumerState<WordListPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    // クエリをリセット
    ref.read(wordSearchQueryProvider.notifier).state = '';
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final wordsAsync = ref.watch(filteredWordListProvider);
    final query = ref.watch(wordSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wordList),
        actions: const [CommonAppBarActions()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
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
            if (query.trim().isEmpty) {
              return Center(child: Text(l10n.noWordsYet));
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '「$query」は登録されていません',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('新規登録する'),
                    onPressed: () =>
                        context.push('/words/add', extra: query.trim()),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            itemCount: words.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final w = words[i];
              return ListTile(
                title: Text(w.word,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(w.meaning,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.volume_up),
                      onPressed: () =>
                          ref.read(ttsServiceProvider).speak(w.word),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
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
