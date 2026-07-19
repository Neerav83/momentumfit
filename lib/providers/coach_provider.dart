import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentumfit/l10n/app_localizations.dart';

import '../core/config/coach_config.dart';
import '../data/ai/groq_coach_client.dart';
import '../domain/services/coach_insights.dart';
import '../domain/services/coach_templates.dart';
import '../domain/services/streak_service.dart';
import 'app_providers.dart';
import 'coach_consent_provider.dart';
import 'locale_provider.dart';

final groqCoachClientProvider = Provider<GroqCoachClient>((ref) {
  final client = GroqCoachClient();
  ref.onDispose(client.dispose);
  return client;
});

String _coachLanguageCode(Locale? preferred) {
  final code = preferred?.languageCode ??
      WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  return code == 'sv' ? 'sv' : 'en';
}

/// Daily coach nudge for Home. Cached per day + workout-done state.
final coachNudgeProvider = FutureProvider<String>((ref) async {
  final profile = ref.watch(profileProvider);
  final streak = ref.watch(streakProvider);
  final workout = ref.watch(todaysWorkoutProvider).asData?.value;
  final levels = ref.watch(levelsProvider);
  final history = ref.watch(workoutHistoryProvider);
  final aiConsent = ref.watch(coachAiConsentProvider);
  final languageCode = _coachLanguageCode(ref.watch(localeProvider));
  final l10n = lookupAppLocalizations(
    languageCode == 'sv' ? const Locale('sv') : const Locale('en'),
  );

  if (profile == null) {
    return l10n.appTagline;
  }

  final insights = CoachInsightBuilder.build(
    profile: profile,
    streak: streak,
    workout: workout,
    history: history,
    levels: levels,
  );

  if (!profile.assessmentCompleted) {
    return CoachTemplates.fromInsights(
      insights,
      languageCode: languageCode,
    );
  }

  final done = workout?.isCompleted ?? false;
  final today = StreakService.dateOnly(DateTime.now());
  final dateKey =
      '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  final store = ref.read(localAppStoreProvider);
  final cacheSuffix =
      '${insights.scenario.name}|$done|ai:$aiConsent|lang:$languageCode';
  final cached = store.readCoachNudge(
    dateKey: '$dateKey|$cacheSuffix',
    workoutDone: done,
  );
  if (cached != null && cached.isNotEmpty) return cached;

  final fallback = CoachTemplates.fromInsights(
    insights,
    languageCode: languageCode,
  );

  // Network AI requires consent + proxy/key.
  if (!aiConsent || !CoachConfig.isNetworkEnabled) {
    await store.writeCoachNudge(
      dateKey: '$dateKey|$cacheSuffix',
      workoutDone: done,
      text: fallback,
    );
    return fallback;
  }

  try {
    final ai = await ref.read(groqCoachClientProvider).generateNudge(
          insights,
          includePrivateDetails: false,
          languageCode: languageCode,
        );
    final text = (ai != null && ai.isNotEmpty) ? ai : fallback;
    await store.writeCoachNudge(
      dateKey: '$dateKey|$cacheSuffix',
      workoutDone: done,
      text: text,
    );
    return text;
  } catch (_) {
    await store.writeCoachNudge(
      dateKey: '$dateKey|$cacheSuffix',
      workoutDone: done,
      text: fallback,
    );
    return fallback;
  }
});
