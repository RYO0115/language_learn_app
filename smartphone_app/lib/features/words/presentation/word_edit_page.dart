import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:language_learn_app/l10n/app_localizations.dart';
import '../data/word_repository.dart';
import '../domain/example_sentence.dart';
import '../domain/word_source.dart';
import '../../ai/data/ai_service.dart';
import '../../settings/presentation/settings_provider.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/utils/storage_monitor.dart';

class WordEditPage extends ConsumerStatefulWidget {
  const WordEditPage({super.key, this.wordId, this.initialWord});

  final int? wordId;
  final String? initialWord;

  @override
  ConsumerState<WordEditPage> createState() => _WordEditPageState();
}

class _WordEditPageState extends ConsumerState<WordEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _wordCtrl = TextEditingController();
  final _readingCtrl = TextEditingController();
  final _meaningCtrl = TextEditingController();
  final _partOfSpeechCtrl = TextEditingController();

  final List<_SentenceFields> _sentences = [];
  final List<_SourceFields> _sources = [];

  bool _isLoading = false;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    if (widget.wordId != null) {
      _loadExisting();
    } else if (widget.initialWord != null) {
      _wordCtrl.text = widget.initialWord!;
    }
  }

  Future<void> _loadExisting() async {
    final word = await ref
        .read(wordRepositoryProvider)
        .getWordById(widget.wordId!);
    if (word == null || !mounted) return;
    _wordCtrl.text = word.word;
    _readingCtrl.text = word.reading ?? '';
    _meaningCtrl.text = word.meaning;
    _partOfSpeechCtrl.text = word.partOfSpeech ?? '';
    setState(() {
      for (final s in word.exampleSentences) {
        _sentences.add(_SentenceFields(en: s.sentenceEn, ja: s.sentenceJa));
      }
    });
  }

  @override
  void dispose() {
    _wordCtrl.dispose();
    _readingCtrl.dispose();
    _meaningCtrl.dispose();
    _partOfSpeechCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEdit = widget.wordId != null;

    return Scaffold(
      appBar: AppBar(
          title: Text(isEdit ? l10n.editWord : l10n.addWord)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _wordCtrl,
                            decoration:
                                InputDecoration(labelText: l10n.wordField),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? l10n.required : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _isGenerating ? null : _generateWithAi,
                          icon: _isGenerating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2))
                              : const Icon(Icons.auto_awesome, size: 16),
                          label: Text(_isGenerating
                              ? l10n.generating
                              : l10n.generateWithAi),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _readingCtrl,
                      decoration:
                          InputDecoration(labelText: l10n.readingField),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _meaningCtrl,
                      decoration:
                          InputDecoration(labelText: l10n.meaningField),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? l10n.required : null,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _partOfSpeechCtrl,
                      decoration:
                          InputDecoration(labelText: l10n.partOfSpeechField),
                    ),
                    const SizedBox(height: 20),
                    Text(l10n.exampleSentence,
                        style: Theme.of(context).textTheme.titleMedium),
                    ..._sentences.asMap().entries.map((e) => _SentenceCard(
                          fields: e.value,
                          onRemove: () =>
                              setState(() => _sentences.removeAt(e.key)),
                        )),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _sentences.add(_SentenceFields())),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addExampleSentence),
                    ),
                    const SizedBox(height: 20),
                    Text(l10n.wordSource,
                        style: Theme.of(context).textTheme.titleMedium),
                    ..._sources.asMap().entries.map((e) => _SourceCard(
                          fields: e.value,
                          onRemove: () =>
                              setState(() => _sources.removeAt(e.key)),
                        )),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _sources.add(_SourceFields())),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addWordSource),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(l10n.save),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _generateWithAi() async {
    final word = _wordCtrl.text.trim();
    if (word.isEmpty) return;
    setState(() => _isGenerating = true);
    try {
      final settings = await ref.read(settingsProvider.future);
      final service = ref.read(aiServiceProvider);
      final provider = service.getProvider(settings);
      final result = await provider.generateWordInfo(word);
      setState(() {
        _readingCtrl.text = result.reading ?? '';
        _meaningCtrl.text = result.meaning;
        _partOfSpeechCtrl.text = result.partOfSpeech ?? '';
        if (result.exampleSentences != null) {
          for (final s in result.exampleSentences!) {
            _sentences.add(_SentenceFields(en: s.sentenceEn, ja: s.sentenceJa));
          }
        }
      });
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final monitor = StorageMonitor();
    if (await monitor.isOverLimit()) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final proceed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(l10n.confirm),
          content: Text(l10n.storageLimitWarning(100)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel)),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.ok)),
          ],
        ),
      );
      if (proceed != true) return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(wordRepositoryProvider);
      final sentences = _sentences
          .map((s) => ExampleSentence(
                id: 0,
                wordId: 0,
                sentenceEn: s.enCtrl.text,
                sentenceJa: s.jaCtrl.text,
              ))
          .toList();
      final sources = _sources
          .map((s) => WordSource(
                id: 0,
                wordId: 0,
                sourceType: s.type,
                title: s.titleCtrl.text.isEmpty ? null : s.titleCtrl.text,
                url: s.urlCtrl.text.isEmpty ? null : s.urlCtrl.text,
                createdAt: DateTime.now(),
              ))
          .toList();

      if (widget.wordId == null) {
        await repo.createWord(
          word: _wordCtrl.text.trim(),
          reading: _readingCtrl.text.trim().isEmpty
              ? null
              : _readingCtrl.text.trim(),
          meaning: _meaningCtrl.text.trim(),
          partOfSpeech: _partOfSpeechCtrl.text.trim().isEmpty
              ? null
              : _partOfSpeechCtrl.text.trim(),
          exampleSentences: sentences,
          sources: sources,
        );
      } else {
        await repo.updateWord(
          id: widget.wordId!,
          word: _wordCtrl.text.trim(),
          reading: _readingCtrl.text.trim().isEmpty
              ? null
              : _readingCtrl.text.trim(),
          meaning: _meaningCtrl.text.trim(),
          partOfSpeech: _partOfSpeechCtrl.text.trim().isEmpty
              ? null
              : _partOfSpeechCtrl.text.trim(),
          exampleSentences: sentences,
          sources: sources,
        );
      }
      if (mounted) context.pop();
    } on DuplicateWordException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                AppLocalizations.of(context)!.duplicateWordError)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _SentenceFields {
  _SentenceFields({String en = '', String ja = ''}) {
    enCtrl = TextEditingController(text: en);
    jaCtrl = TextEditingController(text: ja);
  }

  late final TextEditingController enCtrl;
  late final TextEditingController jaCtrl;
}

class _SourceFields {
  _SourceFields() {
    titleCtrl = TextEditingController();
    urlCtrl = TextEditingController();
  }

  late final TextEditingController titleCtrl;
  late final TextEditingController urlCtrl;
  SourceType type = SourceType.other;
}

class _SentenceCard extends StatelessWidget {
  const _SentenceCard({required this.fields, required this.onRemove});

  final _SentenceFields fields;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text(l10n.exampleSentence)),
                IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.close, size: 18)),
              ],
            ),
            TextField(
              controller: fields.enCtrl,
              decoration: InputDecoration(labelText: l10n.exampleSentenceEn),
            ),
            TextField(
              controller: fields.jaCtrl,
              decoration: InputDecoration(labelText: l10n.exampleSentenceJa),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceCard extends StatefulWidget {
  const _SourceCard({required this.fields, required this.onRemove});

  final _SourceFields fields;
  final VoidCallback onRemove;

  @override
  State<_SourceCard> createState() => _SourceCardState();
}

class _SourceCardState extends State<_SourceCard> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text(l10n.wordSource)),
                IconButton(
                    onPressed: widget.onRemove,
                    icon: const Icon(Icons.close, size: 18)),
              ],
            ),
            DropdownButtonFormField<SourceType>(
              value: widget.fields.type,
              items: SourceType.values
                  .map((t) =>
                      DropdownMenuItem(value: t, child: Text(t.name)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => widget.fields.type = v ?? SourceType.other),
            ),
            TextField(
              controller: widget.fields.titleCtrl,
              decoration: const InputDecoration(labelText: 'タイトル'),
            ),
            TextField(
              controller: widget.fields.urlCtrl,
              decoration: const InputDecoration(labelText: 'URL'),
            ),
          ],
        ),
      ),
    );
  }
}
