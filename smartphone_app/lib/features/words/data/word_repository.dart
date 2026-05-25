import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/utils/date_utils.dart';
import '../domain/example_sentence.dart' as domain;
import '../domain/word.dart' as domain;
import '../domain/word_source.dart' as domain;
import 'word_dao.dart';

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return WordRepository(WordDao(db));
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

class WordRepository {
  WordRepository(this._dao);

  final WordDao _dao;

  Future<List<domain.Word>> getAllWords() async {
    final rows = await _dao.getAllWords();
    return Future.wait(rows.map(_toWordWithRelations));
  }

  Stream<List<domain.Word>> watchAllWords() {
    return _dao.watchAllWords().asyncMap(
          (rows) => Future.wait(rows.map(_toWordWithRelations)),
        );
  }

  Future<domain.Word?> getWordById(int id) async {
    final row = await _dao.getWordById(id);
    if (row == null) return null;
    return _toWordWithRelations(row);
  }

  Future<bool> existsByText(String wordText) async {
    final row = await _dao.getWordByText(wordText);
    return row != null;
  }

  Future<domain.Word> createWord({
    required String word,
    String? reading,
    required String meaning,
    String? partOfSpeech,
    List<domain.ExampleSentence> exampleSentences = const [],
    List<domain.WordSource> sources = const [],
  }) async {
    if (await existsByText(word)) {
      throw DuplicateWordException(word);
    }
    final now = DateTime.now().toUnixTimestamp();
    final id = await _dao.insertWord(WordsCompanion.insert(
      word: word,
      reading: Value(reading),
      meaning: meaning,
      partOfSpeech: Value(partOfSpeech),
      createdAt: now,
      updatedAt: now,
    ));
    for (var i = 0; i < exampleSentences.length; i++) {
      final s = exampleSentences[i];
      await _dao.insertExampleSentence(ExampleSentencesCompanion.insert(
        wordId: id,
        sentenceEn: s.sentenceEn,
        sentenceJa: s.sentenceJa,
        order: Value(i),
        label: Value(s.label),
      ));
    }
    for (final src in sources) {
      await _dao.insertWordSource(WordSourcesCompanion.insert(
        wordId: id,
        sourceType: src.sourceType.name,
        title: Value(src.title),
        url: Value(src.url),
        pageNumber: Value(src.pageNumber),
        detail: Value(src.detail),
        createdAt: now,
      ));
    }
    return (await getWordById(id))!;
  }

  Future<domain.Word> updateWord({
    required int id,
    required String word,
    String? reading,
    required String meaning,
    String? partOfSpeech,
    List<domain.ExampleSentence> exampleSentences = const [],
    List<domain.WordSource> sources = const [],
  }) async {
    final existing = await _dao.getWordByText(word);
    if (existing != null && existing.id != id) {
      throw DuplicateWordException(word);
    }
    final now = DateTime.now().toUnixTimestamp();
    await _dao.updateWord(WordsCompanion(
      id: Value(id),
      word: Value(word),
      reading: Value(reading),
      meaning: Value(meaning),
      partOfSpeech: Value(partOfSpeech),
      updatedAt: Value(now),
    ));
    await _dao.deleteExampleSentencesByWordId(id);
    await _dao.deleteWordSourcesByWordId(id);
    for (var i = 0; i < exampleSentences.length; i++) {
      final s = exampleSentences[i];
      await _dao.insertExampleSentence(ExampleSentencesCompanion.insert(
        wordId: id,
        sentenceEn: s.sentenceEn,
        sentenceJa: s.sentenceJa,
        order: Value(i),
        label: Value(s.label),
      ));
    }
    for (final src in sources) {
      await _dao.insertWordSource(WordSourcesCompanion.insert(
        wordId: id,
        sourceType: src.sourceType.name,
        title: Value(src.title),
        url: Value(src.url),
        pageNumber: Value(src.pageNumber),
        detail: Value(src.detail),
        createdAt: now,
      ));
    }
    return (await getWordById(id))!;
  }

  Future<void> deleteWord(int id) => _dao.deleteWord(id);

  Future<int> countWords() => _dao.countWords();

  Future<domain.Word> _toWordWithRelations(Word row) async {
    final sentences = await _dao.getExampleSentences(row.id);
    final srcs = await _dao.getWordSources(row.id);
    return domain.Word(
      id: row.id,
      word: row.word,
      reading: row.reading,
      meaning: row.meaning,
      partOfSpeech: row.partOfSpeech,
      createdAt: row.createdAt.toDateTime(),
      updatedAt: row.updatedAt.toDateTime(),
      exampleSentences: sentences
          .map((s) => domain.ExampleSentence(
                id: s.id,
                wordId: s.wordId,
                sentenceEn: s.sentenceEn,
                sentenceJa: s.sentenceJa,
                order: s.order,
                label: s.label,
              ))
          .toList(),
      sources: srcs
          .map((src) => domain.WordSource(
                id: src.id,
                wordId: src.wordId,
                sourceType: domain.SourceType.values
                    .byName(src.sourceType),
                title: src.title,
                url: src.url,
                pageNumber: src.pageNumber,
                detail: src.detail,
                createdAt: src.createdAt.toDateTime(),
              ))
          .toList(),
    );
  }
}
