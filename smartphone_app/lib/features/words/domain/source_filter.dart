import '../domain/word.dart';
import '../domain/word_source.dart';

class SourceFilter {
  const SourceFilter({this.sourceType, this.title});

  final SourceType? sourceType;
  final String? title;

  bool get isEmpty => sourceType == null && title == null;

  bool matchesWord(Word word) {
    if (isEmpty) return true;
    return word.sources.any((s) =>
        (sourceType == null || s.sourceType == sourceType) &&
        (title == null || s.title == title));
  }
}
