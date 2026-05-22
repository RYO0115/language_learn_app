class ExampleSentence {
  const ExampleSentence({
    required this.id,
    required this.wordId,
    required this.sentenceEn,
    required this.sentenceJa,
    this.order = 0,
    this.label,
  });

  final int id;
  final int wordId;
  final String sentenceEn;
  final String sentenceJa;
  final int order;
  final String? label;
}
