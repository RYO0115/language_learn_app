import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../common/widgets/ad_scaffold.dart';
import '../../../common/widgets/common_app_bar_actions.dart';
import '../../words/domain/source_filter.dart';
import '../../words/domain/word_source.dart';
import '../../words/presentation/word_list_provider.dart';
import 'quiz_provider.dart';

class QuizCustomPage extends ConsumerStatefulWidget {
  const QuizCustomPage({super.key});

  @override
  ConsumerState<QuizCustomPage> createState() => _QuizCustomPageState();
}

class _QuizCustomPageState extends ConsumerState<QuizCustomPage> {
  SourceType? _selectedType;
  String? _selectedTitle;

  static const _typeLabels = {
    SourceType.book: '書籍',
    SourceType.website: 'ウェブ',
    SourceType.video: '動画',
    SourceType.other: 'その他',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allWords = ref.watch(wordListProvider).valueOrNull ?? [];
    final titles = ref.watch(distinctSourceTitlesProvider(_selectedType));

    final filter =
        SourceFilter(sourceType: _selectedType, title: _selectedTitle);
    final filteredCount = filter.isEmpty
        ? allWords.length
        : allWords.where(filter.matchesWord).length;

    return AdScaffold(
      appBar: AppBar(
        title: const Text('カスタムクイズ'),
        actions: const [CommonAppBarActions()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('出典タイプ', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                FilterChip(
                  label: const Text('すべて'),
                  selected: _selectedType == null,
                  onSelected: (_) => setState(() {
                    _selectedType = null;
                    _selectedTitle = null;
                  }),
                ),
                ...SourceType.values.map((type) => FilterChip(
                      label: Text(_typeLabels[type]!),
                      selected: _selectedType == type,
                      onSelected: (selected) => setState(() {
                        _selectedType = selected ? type : null;
                        _selectedTitle = null;
                      }),
                    )),
              ],
            ),
            if (_selectedType != null) ...[
              const SizedBox(height: 20),
              Text('タイトル', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              if (titles.isEmpty)
                Text(
                  'この出典タイプの単語はまだ登録されていません',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.outline),
                )
              else
                InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _selectedTitle,
                      isExpanded: true,
                      isDense: true,
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('すべて')),
                        ...titles.map((t) =>
                            DropdownMenuItem(value: t, child: Text(t))),
                      ],
                      onChanged: (v) =>
                          setState(() => _selectedTitle = v),
                    ),
                  ),
                ),
            ],
            const Spacer(),
            Center(
              child: Column(
                children: [
                  Text(
                    '対象単語',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                  Text(
                    '$filteredCount 件',
                    style: theme.textTheme.displaySmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.quiz),
                label: const Text('クイズを開始',
                    style: TextStyle(fontSize: 18)),
                onPressed: filteredCount == 0 ? null : _startQuiz,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startQuiz() {
    final filter =
        SourceFilter(sourceType: _selectedType, title: _selectedTitle);
    ref.read(quizSourceFilterProvider.notifier).state =
        filter.isEmpty ? null : filter;
    context.push('/quiz');
  }
}
