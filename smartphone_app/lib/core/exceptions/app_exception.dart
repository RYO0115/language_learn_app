sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class DuplicateWordException extends AppException {
  const DuplicateWordException(String word)
      : super('Word already exists: $word');
}

class AiGenerationException extends AppException {
  const AiGenerationException(super.message);
}

class StorageOverLimitException extends AppException {
  const StorageOverLimitException(int limitMb)
      : super('Database size exceeds limit: ${limitMb}MB');
}

class ApiKeyNotFoundException extends AppException {
  const ApiKeyNotFoundException(String provider)
      : super('API key not set for: $provider');
}

class ImportException extends AppException {
  const ImportException(super.message);
}
