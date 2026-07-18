import 'coach_insights.dart';

/// Offline / fallback coach lines — always tied to real insights.
abstract final class CoachTemplates {
  static String fromInsights(CoachInsights insights) {
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
        return 'New personal best! '
            'Today you completed ${pr.unit.format(pr.to)} on ${pr.name.toLowerCase()}'
            '${pr.from > 0 ? ', up from ${pr.unit.format(pr.from)}' : ''}. '
            'Fantastic work.';

      case CoachScenario.improvement:
        final best = insights.improvements.first;
        return 'A while ago you completed ${best.unit.format(best.from)} on ${best.name.toLowerCase()}. '
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
}
