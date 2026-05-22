import 'example_sentence.dart';
import 'word_source.dart';

class Word {
  const Word({
    required this.id,
    required this.word,
    this.reading,
    required this.meaning,
    this.partOfSpeech,
    required this.createdAt,
    required this.updatedAt,
    this.exampleSentences = const [],
    this.sources = const [],
  });

  final int id;
  final String word;
  final String? reading;
  final String meaning;
  final String? partOfSpeech;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ExampleSentence> exampleSentences;
  final List<WordSource> sources;

  Word copyWith({
    String? word,
    String? reading,
    String? meaning,
    String? partOfSpeech,
    List<ExampleSentence>? exampleSentences,
    List<WordSource>? sources,
  }) {
    return Word(
      id: id,
      word: word ?? this.word,
      reading: reading ?? this.reading,
      meaning: meaning ?? this.meaning,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      exampleSentences: exampleSentences ?? this.exampleSentences,
      sources: sources ?? this.sources,
    );
  }
}
