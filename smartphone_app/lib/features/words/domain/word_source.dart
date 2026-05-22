enum SourceType { book, website, video, other }

class WordSource {
  const WordSource({
    required this.id,
    required this.wordId,
    required this.sourceType,
    this.title,
    this.url,
    this.pageNumber,
    this.detail,
    required this.createdAt,
  });

  final int id;
  final int wordId;
  final SourceType sourceType;
  final String? title;
  final String? url;
  final String? pageNumber;
  final String? detail;
  final DateTime createdAt;
}
