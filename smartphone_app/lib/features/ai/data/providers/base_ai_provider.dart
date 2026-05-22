import '../../domain/ai_generate_response.dart';

abstract class BaseAiProvider {
  Future<AiGenerateResponse> generateWordInfo(String word);
}
