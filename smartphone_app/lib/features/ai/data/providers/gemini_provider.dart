import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../domain/ai_generate_response.dart';
import 'base_ai_provider.dart';

class GeminiProvider implements BaseAiProvider {
  GeminiProvider({required this.apiKey});

  final String apiKey;
  final _dio = Dio();

  static const _model = 'gemini-1.5-flash';
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  @override
  Future<AiGenerateResponse> generateWordInfo(String word) async {
    final prompt = _buildPrompt(word);
    try {
      final response = await _dio.post(
        '$_endpoint?key=$apiKey',
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'responseMimeType': 'application/json',
          },
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );
      final text = response.data['candidates'][0]['content']['parts'][0]['text']
          as String;
      final json = jsonDecode(text) as Map<String, dynamic>;
      return AiGenerateResponse.fromJson(json);
    } on DioException catch (e) {
      throw AiGenerationException(e.message ?? 'Gemini API error');
    } catch (e) {
      throw AiGenerationException(e.toString());
    }
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
