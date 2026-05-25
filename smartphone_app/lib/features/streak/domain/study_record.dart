class StudyRecord {
  const StudyRecord({
    required this.id,
    required this.studyDate,
    required this.wordsStudied,
    required this.quizCompleted,
  });

  final int id;
  final String studyDate; // YYYY-MM-DD
  final int wordsStudied;
  final int quizCompleted;
}
