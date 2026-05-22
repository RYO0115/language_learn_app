class QuizSession {
  const QuizSession({
    required this.id,
    required this.startedAt,
    this.completedAt,
  });

  final int id;
  final DateTime startedAt;
  final DateTime? completedAt;

  bool get isCompleted => completedAt != null;
}
