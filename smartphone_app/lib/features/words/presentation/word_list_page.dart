import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:language_learn_app/l10n/app_localizations.dart';
import '../../../common/widgets/ad_scaffold.dart';
import '../../../common/widgets/common_app_bar_actions.dart';
import '../../../core/purchase/purchase_provider.dart';
import '../../../core/tts/tts_service.dart';
import '../../settings/presentation/settings_provider.dart';
import '../data/word_repository.dart';
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


  Future<void> _onAddWord(BuildContext context, WidgetRef ref, String query) async {
    final isPremium = ref.read(settingsProvider).valueOrNull?.isPremium ?? false;
    if (!isPremium) {
      final count = await ref.read(wordRepositoryProvider).countWords();
      if (count >= kFreeWordLimit) {
        if (!context.mounted) return;
        _showLimitDialog(context, ref);
        return;
      }
    }
    if (context.mounted) {
      context.push('/words/add', extra: query.trim().isNotEmpty ? query.trim() : null);
    }
  }

  void _showLimitDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('登録上限に達しました'),
        content: const Text(
          '無料版では単語を1,000件まで登録できます。\nプレミアムにアップグレードすると上限が解除されます。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/settings');
            },
            child: const Text('プレミアムへ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final wordsAsync = ref.watch(filteredWordListProvider);
    final query = ref.watch(wordSearchQueryProvider);
    final wordCount = ref.watch(wordCountProvider).valueOrNull ?? 0;
    final isPremium = ref.watch(settingsProvider).valueOrNull?.isPremium ?? false;

    return AdScaffold(
      appBar: AppBar(
        title: Text(l10n.wordList),
        actions: const [CommonAppBarActions()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              children: [
                TextField(
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
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    isPremium
                        ? '$wordCount件（無制限）'
                        : '$wordCount / $kFreeWordLimit件',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: (!isPremium && wordCount >= kFreeWordLimit)
                              ? Colors.red
                              : null,
                        ),
                  ),
                ),
              ],
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
                    onPressed: () => _onAddWord(context, ref, query),
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
        onPressed: () => _onAddWord(context, ref, ''),
        child: const Icon(Icons.add),
      ),
    );
  }
}
