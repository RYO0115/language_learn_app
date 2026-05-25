class QuizAnswer {
  const QuizAnswer({
    required this.id,
    required this.sessionId,
    required this.wordId,
    required this.isCorrect,
    required this.answeredAt,
  });

  final int id;
  final int sessionId;
  final int wordId;
  final bool isCorrect;
  final DateTime answeredAt;
}
