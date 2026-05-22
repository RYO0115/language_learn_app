import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:language_learn_app/features/words/data/word_dao.dart';
import 'package:language_learn_app/features/words/data/word_repository.dart';
import 'package:language_learn_app/core/exceptions/app_exception.dart';
import 'package:language_learn_app/core/database/app_database.dart';

class MockWordDao extends Mock implements WordDao {}

// drift Companion は Fake で代用
class FakeWordsCompanion extends Fake implements WordsCompanion {}
class FakeExampleSentencesCompanion extends Fake
    implements ExampleSentencesCompanion {}
class FakeWordSourcesCompanion extends Fake implements WordSourcesCompanion {}

void main() {
  late MockWordDao mockDao;
  late WordRepository repo;

  setUpAll(() {
    registerFallbackValue(FakeWordsCompanion());
    registerFallbackValue(FakeExampleSentencesCompanion());
    registerFallbackValue(FakeWordSourcesCompanion());
  });

  setUp(() {
    mockDao = MockWordDao();
    repo = WordRepository(mockDao);
  });

  group('WordRepository', () {
    test('T-W-01: creates word successfully', () async {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      when(() => mockDao.getWordByText('apple')).thenAnswer((_) async => null);
      when(() => mockDao.insertWord(any())).thenAnswer((_) async => 1);
      when(() => mockDao.getExampleSentences(1))
          .thenAnswer((_) async => []);
      when(() => mockDao.getWordSources(1)).thenAnswer((_) async => []);
      when(() => mockDao.getWordById(1)).thenAnswer((_) async => Word(
            id: 1,
            word: 'apple',
            reading: '/ˈæpəl/',
            meaning: 'りんご',
            partOfSpeech: 'noun',
            createdAt: now,
            updatedAt: now,
          ));

      final result = await repo.createWord(word: 'apple', meaning: 'りんご');
      expect(result.word, 'apple');
      expect(result.meaning, 'りんご');
    });

    test('T-W-02: throws DuplicateWordException for duplicate', () async {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      when(() => mockDao.getWordByText('apple')).thenAnswer((_) async => Word(
            id: 1,
            word: 'apple',
            reading: null,
            meaning: 'りんご',
            partOfSpeech: null,
            createdAt: now,
            updatedAt: now,
          ));

      expect(
        () => repo.createWord(word: 'apple', meaning: 'りんご'),
        throwsA(isA<DuplicateWordException>()),
      );
    });
  });
}
