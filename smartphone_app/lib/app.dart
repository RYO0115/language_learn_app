import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/dashboard/presentation/dashboard_page.dart';
import 'features/words/presentation/word_list_page.dart';
import 'features/words/presentation/word_detail_page.dart';
import 'features/words/presentation/word_edit_page.dart';
import 'features/quiz/presentation/quiz_custom_page.dart';
import 'features/quiz/presentation/quiz_page.dart';
import 'features/quiz/presentation/quiz_result_page.dart';
import 'features/streak/presentation/streak_calendar_page.dart';
import 'features/export/presentation/export_page.dart';
import 'features/settings/presentation/settings_page.dart';
import 'features/settings/presentation/settings_ai_page.dart';
import 'features/settings/presentation/settings_quiz_page.dart';
import 'features/settings/presentation/settings_words_page.dart';
import 'features/onboarding/presentation/api_key_setup_page.dart';
import 'features/settings/presentation/settings_provider.dart';
import 'package:language_learn_app/l10n/app_localizations.dart';

final _routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final settings = ref.read(settingsProvider);
      final hasKey = settings.whenOrNull(
            data: (s) => s.hasAnyApiKey,
          ) ??
          false;
      final isOnboarding = state.matchedLocation == '/onboarding';
      if (!hasKey && !isOnboarding) return '/onboarding';
      if (hasKey && isOnboarding) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (_, __) => const ApiKeySetupPage()),
      GoRoute(path: '/', builder: (_, __) => const DashboardPage()),
      GoRoute(path: '/words', builder: (_, __) => const WordListPage()),
      GoRoute(
        path: '/words/add',
        builder: (_, state) =>
            WordEditPage(initialWord: state.extra as String?),
      ),
      GoRoute(
        path: '/words/:id',
        builder: (_, state) =>
            WordDetailPage(wordId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/words/:id/edit',
        builder: (_, state) =>
            WordEditPage(wordId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(path: '/quiz', builder: (_, __) => const QuizPage()),
      GoRoute(path: '/quiz/custom', builder: (_, __) => const QuizCustomPage()),
      GoRoute(
        path: '/quiz/result/:sessionId',
        builder: (_, state) => QuizResultPage(
            sessionId: int.parse(state.pathParameters['sessionId']!)),
      ),
      GoRoute(path: '/streak', builder: (_, __) => const StreakCalendarPage()),
      GoRoute(path: '/export', builder: (_, __) => const ExportPage()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
      GoRoute(path: '/settings/ai', builder: (_, __) => const SettingsAiPage()),
      GoRoute(path: '/settings/quiz', builder: (_, __) => const SettingsQuizPage()),
      GoRoute(path: '/settings/words', builder: (_, __) => const SettingsWordsPage()),
    ],
  );
});

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);
    return MaterialApp.router(
      title: 'Language Learn App',
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ja')],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
    );
  }
}
