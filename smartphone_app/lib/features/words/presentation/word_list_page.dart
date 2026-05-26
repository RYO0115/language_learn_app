import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:language_learn_app/l10n/app_localizations.dart';
import '../../../common/widgets/ad_scaffold.dart';
import '../../../common/widgets/common_app_bar_actions.dart';
import '../../../core/purchase/purchase_provider.dart';
import '../../../core/tts/tts_service.dart';
import '../../quiz/presentation/quiz_provider.dart';
import '../../settings/presentation/settings_provider.dart';
import '../data/word_repository.dart';
import '../domain/source_filter.dart';
import '../domain/word_source.dart';
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
    ref.read(wordSearchQueryProvider.notifier).state = '';
    ref.read(sourceFilterProvider.notifier).state = const SourceFilter();
    super.dispose();
  }

  Future<void> _onAddWord(String query) async {
    final isPremium =
        ref.read(settingsProvider).valueOrNull?.isPremium ?? false;
    if (!isPremium) {
      final count = await ref.read(wordRepositoryProvider).countWords();
      if (count >= kFreeWordLimit) {
        if (!mounted) return;
        _showLimitDialog();
        return;
      }
    }
    if (mounted) {
      context.push(
          '/words/add', extra: query.trim().isNotEmpty ? query.trim() : null);
    }
  }

  void _showLimitDialog() {
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

  void _startFilteredQuiz(SourceFilter filter) {
    ref.read(quizSourceFilterProvider.notifier).state = filter;
    context.push('/quiz');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final wordsAsync = ref.watch(filteredWordListProvider);
    final query = ref.watch(wordSearchQueryProvider);
    final filter = ref.watch(sourceFilterProvider);
    final wordCount = ref.watch(wordCountProvider).valueOrNull ?? 0;
    final isPremium =
        ref.watch(settingsProvider).valueOrNull?.isPremium ?? false;

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
      body: Column(
        children: [
          _SourceFilterBar(filter: filter, ref: ref),
          Expanded(
            child: wordsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (words) {
                if (words.isEmpty) {
                  if (query.trim().isEmpty && filter.isEmpty) {
                    return Center(child: Text(l10n.noWordsYet));
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          filter.isEmpty
                              ? '「$query」は登録されていません'
                              : '該当する単語がありません',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        if (query.trim().isNotEmpty && filter.isEmpty) ...[
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('新規登録する'),
                            onPressed: () => _onAddWord(query),
                          ),
                        ],
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
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(w.meaning,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
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
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!filter.isEmpty) ...[
            FloatingActionButton.extended(
              heroTag: 'quiz_fab',
              onPressed: () => _startFilteredQuiz(filter),
              icon: const Icon(Icons.quiz),
              label: Text(
                '${wordsAsync.valueOrNull?.length ?? 0}件でクイズ',
              ),
              backgroundColor: Colors.green,
            ),
            const SizedBox(height: 12),
          ],
          FloatingActionButton(
            heroTag: 'add_fab',
            onPressed: () => _onAddWord(''),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _SourceFilterBar extends StatelessWidget {
  const _SourceFilterBar({required this.filter, required this.ref});

  final SourceFilter filter;
  final WidgetRef ref;

  static const _typeLabels = {
    SourceType.book: '書籍',
    SourceType.website: 'ウェブ',
    SourceType.video: '動画',
    SourceType.other: 'その他',
  };

  @override
  Widget build(BuildContext context) {
    final availableTitles =
        ref.watch(distinctSourceTitlesProvider(filter.sourceType));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
          child: Row(
            children: [
              FilterChip(
                label: const Text('すべて'),
                selected: filter.isEmpty,
                onSelected: (_) => ref
                    .read(sourceFilterProvider.notifier)
                    .state = const SourceFilter(),
              ),
              ...SourceType.values.map((type) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(_typeLabels[type]!),
                      selected: filter.sourceType == type,
                      onSelected: (selected) {
                        ref.read(sourceFilterProvider.notifier).state =
                            selected
                                ? SourceFilter(sourceType: type)
                                : const SourceFilter();
                      },
                    ),
                  )),
            ],
          ),
        ),
        if (filter.sourceType != null && availableTitles.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                isDense: true,
                value: filter.title,
                hint: const Text('タイトルで絞り込む'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('すべて')),
                  ...availableTitles.map(
                    (t) => DropdownMenuItem(value: t, child: Text(t)),
                  ),
                ],
                onChanged: (title) {
                  ref.read(sourceFilterProvider.notifier).state =
                      SourceFilter(
                    sourceType: filter.sourceType,
                    title: title,
                  );
                },
              ),
            ),
          ),
        const Divider(height: 1),
      ],
    );
  }
}
