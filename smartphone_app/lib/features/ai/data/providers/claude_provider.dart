import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../domain/ai_generate_response.dart';
import 'base_ai_provider.dart';

class ClaudeProvider implements BaseAiProvider {
  ClaudeProvider({required this.apiKey});

  final String apiKey;
  final _dio = Dio();

  static const _model = 'claude-haiku-4-5-20251001';
  static const _endpoint = 'https://api.anthropic.com/v1/messages';

  @override
  Future<AiGenerateResponse> generateWordInfo(String word) async {
    final prompt = _buildPrompt(word);
    try {
      final response = await _dio.post(
        _endpoint,
        data: {
          'model': _model,
          'max_tokens': 512,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        },
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );
      final text =
          response.data['content'][0]['text'] as String;
      final jsonStr = _extractJson(text);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return AiGenerateResponse.fromJson(json);
    } on DioException catch (e) {
      throw AiGenerationException(e.message ?? 'Claude API error');
    } catch (e) {
      throw AiGenerationException(e.toString());
    }
  }

  String _extractJson(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start == -1 || end == -1) return text;
    return text.substring(start, end + 1);
  }

  String _buildPrompt(String word) => '''
英単語 "$word" について以下の JSON 形式で回答してください。
{
  "meaning": "日本語の意味（簡潔に）",
  "reading": "発音記号（IPA）",
  "part_of_speech": "品詞（名詞/動詞/形容詞など）",
  "example_sentences": [
    {"sentence_en": "例文（英語）", "sentence_ja": "例文（日本語訳）"}
  ]
}
JSON のみ返答してください。説明文は不要です。
''';
}
