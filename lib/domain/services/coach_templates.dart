import 'coach_insights.dart';

/// Offline / fallback coach lines — always tied to real insights.
abstract final class CoachTemplates {
  static String fromInsights(
    CoachInsights insights, {
    String languageCode = 'en',
  }) {
    return languageCode == 'sv'
        ? _swedish(insights)
        : _english(insights);
  }

  static String _exerciseName(String exerciseId, String englishName, bool sv) {
    if (!sv) return englishName.toLowerCase();
    return switch (exerciseId) {
      'push_ups' => 'armhävningar',
      'knee_push_ups' => 'knäarmhävningar',
      'chair_dips' => 'stoldips',
      'squats' => 'knäböj',
      'lunges' => 'utfall',
      'glute_bridge' => 'höftlyft',
      'calf_raises' => 'tåhävningar',
      'plank' => 'plankan',
      'side_plank' => 'sidplankan',
      'dead_bug' => 'dödskalbaggen',
      'bird_dog' => 'fågelhund',
      'jumping_jacks' => 'hopptomtar',
      'high_knees' => 'höga knän',
      'mountain_climbers' => 'bergsklättrare',
      _ => englishName.toLowerCase(),
    };
  }

  static String _english(CoachInsights insights) {
    final name = insights.profile.name;
    final streak = insights.streak.currentStreak;

    switch (insights.scenario) {
      case CoachScenario.firstWorkout:
        return 'Great job completing your very first workout, $name. '
            'The hardest part is getting started, and you\'ve already done it. '
            'Tomorrow we\'ll continue building your momentum.';

      case CoachScenario.weekStreak:
        return 'Seven days in a row. '
            'You\'re no longer just exercising — you\'re building a habit. '
            'Keep showing up.';

      case CoachScenario.longStreak:
        return '$streak days. '
            'This isn\'t motivation anymore. '
            'This is becoming part of who you are.';

      case CoachScenario.missedDay:
        return 'Everyone misses a day sometimes. '
            'Don\'t focus on the streak you lost. '
            'Focus on the next workout — let\'s build it back together.';

      case CoachScenario.personalRecord:
        final pr = insights.personalRecordsToday.first;
        final exercise = _exerciseName(pr.exerciseId, pr.name, false);
        return 'New personal best! '
            'Today you completed ${pr.unit.format(pr.to)} on $exercise'
            '${pr.from > 0 ? ', up from ${pr.unit.format(pr.from)}' : ''}. '
            'Fantastic work.';

      case CoachScenario.improvement:
        final best = insights.improvements.first;
        final exercise = _exerciseName(best.exerciseId, best.name, false);
        return 'A while ago you completed ${best.unit.format(best.from)} on $exercise. '
            'Recently you hit ${best.unit.format(best.to)} — that\'s a ${best.percentGain}% improvement. '
            'Your consistency is paying off.';

      case CoachScenario.workoutDifficult:
        return 'I noticed today\'s workout was tougher than usual'
            '${insights.todayCompletionPercent != null ? ' (${(insights.todayCompletionPercent! * 100).round()}% of target)' : ''}. '
            'Tomorrow I\'ll keep the difficulty about the same so you can recover while still making progress.';

      case CoachScenario.workoutEasy:
        return 'Today\'s workout looked comfortable. '
            'I\'ll increase tomorrow\'s challenge slightly. '
            'You\'re ready.';

      case CoachScenario.monthlySummary:
        final m = insights.monthlyStats!;
        final lines = m.improvements.take(3).map((p) => p.formatted).toList();
        final progress = lines.isEmpty
            ? 'Your consistency this month is what matters most.'
            : lines.join('. ');
        return 'This month you completed ${m.workoutsCompleted} workouts '
            '(longest streak in the period: ${m.longestStreakInPeriod}). '
            '$progress Amazing progress — let\'s keep building momentum.';

      case CoachScenario.afterWorkout:
        return 'Nice work today, $name. '
            'Streak: $streak day${streak == 1 ? '' : 's'}. '
            'See you tomorrow for the next small step.';

      case CoachScenario.beforeWorkout:
        if (insights.missedYesterday) {
          return 'Everyone misses a day sometimes. '
              'Today\'s workout is waiting — short, achievable, and enough.';
        }
        if (streak >= 7) {
          return 'Day ${streak + 1} is ready, $name. '
              'A few focused moves. Keep the streak honest and easy.';
        }
        if (insights.totalCompletedWorkouts == 0) {
          return 'Your first workout is ready, $name. '
              'Start light. Showing up is the whole game.';
        }
        final count = insights.workout?.exercises.length ?? 0;
        return 'Today\'s session has $count moves. '
            'Based on your recent training, keep form clean and finish what you can.';
    }
  }

  static String _swedish(CoachInsights insights) {
    final name = insights.profile.name;
    final streak = insights.streak.currentStreak;

    switch (insights.scenario) {
      case CoachScenario.firstWorkout:
        return 'Bra jobbat med ditt allra första pass, $name. '
            'Det svåraste är att börja — och det har du redan gjort. '
            'Imorgon fortsätter vi bygga ditt momentum.';

      case CoachScenario.weekStreak:
        return 'Sju dagar i rad. '
            'Du tränar inte bara längre — du bygger en vana. '
            'Fortsätt dyka upp.';

      case CoachScenario.longStreak:
        return '$streak dagar. '
            'Det här handlar inte om motivation längre. '
            'Det börjar bli en del av vem du är.';

      case CoachScenario.missedDay:
        return 'Alla missar en dag ibland. '
            'Fokusera inte på streaken du tappade. '
            'Fokusera på nästa pass — vi bygger upp den tillsammans.';

      case CoachScenario.personalRecord:
        final pr = insights.personalRecordsToday.first;
        final exercise = _exerciseName(pr.exerciseId, pr.name, true);
        return 'Nytt personligt rekord! '
            'Idag klarade du ${pr.unit.format(pr.to)} på $exercise'
            '${pr.from > 0 ? ', upp från ${pr.unit.format(pr.from)}' : ''}. '
            'Fantastiskt jobbat.';

      case CoachScenario.improvement:
        final best = insights.improvements.first;
        final exercise = _exerciseName(best.exerciseId, best.name, true);
        return 'För ett tag sedan klarade du ${best.unit.format(best.from)} på $exercise. '
            'Nyligen nådde du ${best.unit.format(best.to)} — det är en förbättring på ${best.percentGain}%. '
            'Din konsekvens ger resultat.';

      case CoachScenario.workoutDifficult:
        return 'Jag märkte att dagens pass var tyngre än vanligt'
            '${insights.todayCompletionPercent != null ? ' (${(insights.todayCompletionPercent! * 100).round()}% av målet)' : ''}. '
            'Imorgon håller jag svårigheten ungefär likadan så du kan återhämta dig och ändå göra framsteg.';

      case CoachScenario.workoutEasy:
        return 'Dagens pass såg ut att gå smidigt. '
            'Jag höjer utmaningen lite imorgon. '
            'Du är redo.';

      case CoachScenario.monthlySummary:
        final m = insights.monthlyStats!;
        final lines = m.improvements.take(3).map((p) {
          final exercise = _exerciseName(p.exerciseId, p.name, true);
          return '$exercise: ${p.unit.format(p.from)} → ${p.unit.format(p.to)} (+${p.percentGain}%)';
        }).toList();
        final progress = lines.isEmpty
            ? 'Din konsekvens den här månaden är det som betyder mest.'
            : lines.join('. ');
        return 'Den här månaden klarade du ${m.workoutsCompleted} pass '
            '(längsta streak under perioden: ${m.longestStreakInPeriod}). '
            '$progress Grymma framsteg — låt oss fortsätta bygga momentum.';

      case CoachScenario.afterWorkout:
        return 'Bra jobbat idag, $name. '
            'Streak: $streak dag${streak == 1 ? '' : 'ar'}. '
            'Vi ses imorgon för nästa lilla steg.';

      case CoachScenario.beforeWorkout:
        if (insights.missedYesterday) {
          return 'Alla missar en dag ibland. '
              'Dagens pass väntar — kort, görbart och tillräckligt.';
        }
        if (streak >= 7) {
          return 'Dag ${streak + 1} är redo, $name. '
              'Några fokuserade övningar. Håll streaken ärlig och enkel.';
        }
        if (insights.totalCompletedWorkouts == 0) {
          return 'Ditt första pass är redo, $name. '
              'Börja lätt. Att dyka upp är hela spelet.';
        }
        final count = insights.workout?.exercises.length ?? 0;
        return 'Dagens pass har $count övningar. '
            'Utifrån din senaste träning: håll formen ren och slutför det du kan.';
    }
  }
}
