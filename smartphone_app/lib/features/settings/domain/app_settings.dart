enum AiProvider { gemini, claude }

enum TtsAccent { american, british }

class AppSettings {
  const AppSettings({
    this.aiProvider = AiProvider.gemini,
    this.googleApiKey,
    this.claudeApiKey,
    this.quizCount = 20,
    this.dbLimitMb = 100,
    this.ttsAccent = TtsAccent.american,
  });

  final AiProvider aiProvider;
  final String? googleApiKey;
  final String? claudeApiKey;
  final int quizCount;
  final int dbLimitMb;
  final TtsAccent ttsAccent;

  bool get hasAnyApiKey =>
      (googleApiKey != null && googleApiKey!.isNotEmpty) ||
      (claudeApiKey != null && claudeApiKey!.isNotEmpty);

  AppSettings copyWith({
    AiProvider? aiProvider,
    String? googleApiKey,
    String? claudeApiKey,
    int? quizCount,
    int? dbLimitMb,
    TtsAccent? ttsAccent,
  }) {
    return AppSettings(
      aiProvider: aiProvider ?? this.aiProvider,
      googleApiKey: googleApiKey ?? this.googleApiKey,
      claudeApiKey: claudeApiKey ?? this.claudeApiKey,
      quizCount: quizCount ?? this.quizCount,
      dbLimitMb: dbLimitMb ?? this.dbLimitMb,
      ttsAccent: ttsAccent ?? this.ttsAccent,
    );
  }
}
