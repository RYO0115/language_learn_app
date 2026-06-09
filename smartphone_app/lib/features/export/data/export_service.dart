import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../words/data/word_repository.dart';
import '../../words/domain/example_sentence.dart' as domain;
import '../../words/domain/word.dart';
import '../../words/domain/word_source.dart' as domain;
import '../../../core/exceptions/app_exception.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(ref.watch(wordRepositoryProvider));
});

class ExportService {
  ExportService(this._wordRepo);

  final WordRepository _wordRepo;

  Future<void> exportJson() async {
    final words = await _wordRepo.getAllWords();
    final data = words.map(_wordToJson).toList();
    final json = const JsonEncoder.withIndent('  ').convert(data);
    final file = await _writeTempFile('words_export.json', json);
    await Share.shareXFiles([XFile(file.path)], text: '単語帳エクスポート');
  }

  Future<void> exportCsv() async {
    final words = await _wordRepo.getAllWords();
    final lines = [
      'word,reading,meaning,part_of_speech',
      ...words.map((w) =>
          '"${w.word}","${w.reading ?? ''}","${w.meaning}","${w.partOfSpeech ?? ''}"'),
    ];
    final csv = lines.join('\n');
    final file = await _writeTempFile('words_export.csv', csv);
    await Share.shareXFiles([XFile(file.path)], text: '単語帳エクスポート');
  }

  Future<int> importJson(String content) async {
    final List<dynamic> data;
    try {
      final decoded = jsonDecode(content);
      if (decoded is List) {
        data = decoded;
      } else if (decoded is Map && decoded['words'] is List) {
        data = decoded['words'] as List<dynamic>;
      } else {
        throw const ImportException('JSON の形式が不正です');
      }
    } catch (e) {
      if (e is ImportException) rethrow;
      throw const ImportException('JSON の形式が不正です');
    }
    var imported = 0;
    for (final item in data) {
      final map = item as Map<String, dynamic>;
      try {
        final sentences = (map['example_sentences'] as List<dynamic>? ?? [])
            .map((s) {
              final sm = s as Map<String, dynamic>;
              return domain.ExampleSentence(
                id: 0,
                wordId: 0,
                sentenceEn: sm['sentence_en'] as String? ?? '',
                sentenceJa: sm['sentence_ja'] as String? ?? '',
                order: sm['order'] as int? ?? 0,
                label: sm['label'] as String?,
              );
            })
            .toList();
        final sources = (map['sources'] as List<dynamic>? ?? [])
            .map((s) {
              final sm = s as Map<String, dynamic>;
              final typeStr = sm['source_type'] as String? ?? 'other';
              final sourceType = domain.SourceType.values.firstWhere(
                (e) => e.name == typeStr,
                orElse: () => domain.SourceType.other,
              );
              return domain.WordSource(
                id: 0,
                wordId: 0,
                sourceType: sourceType,
                title: sm['title'] as String?,
                url: sm['url'] as String?,
                pageNumber: sm['page_number'] as String?,
                detail: sm['detail'] as String?,
                createdAt: DateTime.now(),
              );
            })
            .toList();
        await _wordRepo.createWord(
          word: map['word'] as String,
          reading: map['reading'] as String?,
          meaning: map['meaning'] as String,
          partOfSpeech: map['part_of_speech'] as String?,
          exampleSentences: sentences,
          sources: sources,
        );
        imported++;
      } on DuplicateWordException {
        // スキップ
      }
    }
    return imported;
  }

  Future<int> importCsv(String content) async {
    final lines = content.split('\n').skip(1); // ヘッダーをスキップ
    var imported = 0;
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final cols = _parseCsvLine(line);
      if (cols.length < 3) continue;
      try {
        await _wordRepo.createWord(
          word: cols[0],
          reading: cols.length > 1 && cols[1].isNotEmpty ? cols[1] : null,
          meaning: cols[2],
          partOfSpeech: cols.length > 3 && cols[3].isNotEmpty ? cols[3] : null,
        );
        imported++;
      } on DuplicateWordException {
        // スキップ
      }
    }
    return imported;
  }

  Map<String, dynamic> _wordToJson(Word w) => {
        'word': w.word,
        'reading': w.reading,
        'meaning': w.meaning,
        'part_of_speech': w.partOfSpeech,
        'example_sentences': w.exampleSentences
            .map((s) => {
                  'sentence_en': s.sentenceEn,
                  'sentence_ja': s.sentenceJa,
                  'order': s.order,
                  'label': s.label,
                })
            .toList(),
        'sources': w.sources
            .map((src) => {
                  'source_type': src.sourceType.name,
                  'title': src.title,
                  'url': src.url,
                  'page_number': src.pageNumber,
                  'detail': src.detail,
                })
            .toList(),
      };

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    final pattern = RegExp(r'"([^"]*)"(?:,|$)|([^,]*)(?:,|$)');
    for (final m in pattern.allMatches(line)) {
      result.add(m.group(1) ?? m.group(2) ?? '');
    }
    return result;
  }

  Future<File> _writeTempFile(String name, String content) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    return file.writeAsString(content);
  }
}
