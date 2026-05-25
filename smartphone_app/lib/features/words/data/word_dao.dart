import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

part 'word_dao.g.dart';

@DriftAccessor(tables: [Words, ExampleSentences, WordSources])
class WordDao extends DatabaseAccessor<AppDatabase> with _$WordDaoMixin {
  WordDao(super.db);

  Future<List<Word>> getAllWords() => select(words).get();

  Stream<List<Word>> watchAllWords() => select(words).watch();

  Future<Word?> getWordById(int id) =>
      (select(words)..where((w) => w.id.equals(id))).getSingleOrNull();

  Future<Word?> getWordByText(String wordText) =>
      (select(words)..where((w) => w.word.equals(wordText))).getSingleOrNull();

  Future<List<ExampleSentence>> getExampleSentences(int wordId) =>
      (select(exampleSentences)
            ..where((e) => e.wordId.equals(wordId))
            ..orderBy([(e) => OrderingTerm.asc(e.order)]))
          .get();

  Future<List<WordSource>> getWordSources(int wordId) =>
      (select(wordSources)..where((s) => s.wordId.equals(wordId))).get();

  Future<int> insertWord(WordsCompanion word) => into(words).insert(word);

  Future<bool> updateWord(WordsCompanion word) => update(words).replace(word);

  Future<int> deleteWord(int id) =>
      (delete(words)..where((w) => w.id.equals(id))).go();

  Future<int> insertExampleSentence(ExampleSentencesCompanion sentence) =>
      into(exampleSentences).insert(sentence);

  Future<int> deleteExampleSentencesByWordId(int wordId) =>
      (delete(exampleSentences)..where((e) => e.wordId.equals(wordId))).go();

  Future<int> insertWordSource(WordSourcesCompanion source) =>
      into(wordSources).insert(source);

  Future<int> deleteWordSourcesByWordId(int wordId) =>
      (delete(wordSources)..where((s) => s.wordId.equals(wordId))).go();

  Future<int> countWords() async {
    final count = countAll();
    final query = selectOnly(words)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }
}
