class AiGeneratedSentence {
  const AiGeneratedSentence({
    required this.sentenceEn,
    required this.sentenceJa,
  });

  final String sentenceEn;
  final String sentenceJa;

  factory AiGeneratedSentence.fromJson(Map<String, dynamic> json) =>
      AiGeneratedSentence(
        sentenceEn: json['sentence_en'] as String,
        sentenceJa: json['sentence_ja'] as String,
      );
}

class AiGenerateResponse {
  const AiGenerateResponse({
    required this.meaning,
    this.reading,
    this.partOfSpeech,
    this.exampleSentences,
  });

  final String meaning;
  final String? reading;
  final String? partOfSpeech;
  final List<AiGeneratedSentence>? exampleSentences;

  factory AiGenerateResponse.fromJson(Map<String, dynamic> json) =>
      AiGenerateResponse(
        meaning: json['meaning'] as String,
        reading: json['reading'] as String?,
        partOfSpeech: json['part_of_speech'] as String?,
        exampleSentences: (json['example_sentences'] as List<dynamic>?)
            ?.map((e) =>
                AiGeneratedSentence.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
