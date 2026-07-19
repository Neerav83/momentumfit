import '../models/enums.dart';
import '../models/exercise.dart';
import '../models/exercise_level.dart';
import '../models/user_profile.dart';
import '../models/workout.dart';
import 'streak_service.dart';

enum CoachScenario {
  firstWorkout,
  weekStreak,
  longStreak,
  missedDay,
  personalRecord,
  improvement,
  workoutDifficult,
  workoutEasy,
  monthlySummary,
  beforeWorkout,
  afterWorkout,
}

class ExerciseProgressFact {
  const ExerciseProgressFact({
    required this.exerciseId,
    required this.name,
    required this.from,
    required this.to,
    required this.unit,
    required this.percentGain,
    required this.isPersonalRecord,
  });

  final String exerciseId;
  final String name;
  final int from;
  final int to;
  final ExerciseUnit unit;
  final int percentGain;
  final bool isPersonalRecord;

  String get formatted =>
      '$name: ${unit.format(from)} → ${unit.format(to)} ($percentGain% improvement)';
}

class CoachInsights {
  const CoachInsights({
    required this.scenario,
    required this.profile,
    required this.streak,
    required this.workout,
    required this.totalCompletedWorkouts,
    required this.todayCompletionPercent,
    required this.previousWorkoutCompletionPercent,
    required this.weekCompletionPercent,
    required this.missedYesterday,
    required this.personalRecordsToday,
    required this.improvements,
    required this.difficultyTrend,
    required this.monthlyStats,
    required this._factsForPrompt,
  });

  final CoachScenario scenario;
  final UserProfile profile;
  final StreakState streak;
  final DailyWorkout? workout;
  final int totalCompletedWorkouts;
  final double? todayCompletionPercent;
  final double? previousWorkoutCompletionPercent;
  final double? weekCompletionPercent;
  final bool missedYesterday;
  final List<ExerciseProgressFact> personalRecordsToday;
  final List<ExerciseProgressFact> improvements;
  final String difficultyTrend;
  final MonthlyCoachStats? monthlyStats;
  final List<String> _factsForPrompt;

  /// Prompt facts. Private fields (name, injuries) are omitted unless opted in.
  List<String> factsForPrompt({bool includePrivateDetails = false}) {
    if (includePrivateDetails) return List.unmodifiable(_factsForPrompt);
    return [
      for (final fact in _factsForPrompt)
        if (!fact.startsWith('Name:') && !fact.startsWith('Injuries:')) fact,
    ];
  }
}

class MonthlyCoachStats {
  const MonthlyCoachStats({
    required this.workoutsCompleted,
    required this.longestStreakInPeriod,
    required this.improvements,
  });

  final int workoutsCompleted;
  final int longestStreakInPeriod;
  final List<ExerciseProgressFact> improvements;
}

/// Builds data-backed coaching insights from local history.
abstract final class CoachInsightBuilder {
  static CoachInsights build({
    required UserProfile profile,
    required StreakState streak,
    required DailyWorkout? workout,
    required List<DailyWorkout> history,
    required Map<String, ExerciseLevel> levels,
    DateTime? now,
  }) {
    final today = StreakService.dateOnly(now ?? DateTime.now());
    final completed = history.where((w) => w.isCompleted).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final doneToday = workout?.isCompleted ?? false;
    final todayPct = _completionPercent(workout);
    final previous = _previousCompleted(completed, today);
    final previousPct = _completionPercent(previous);
    final weekPct = _weekCompletionPercent(completed, today);
    final missedYesterday = _missedYesterday(streak, today, completed);

    final prsToday = doneToday
        ? _personalRecordsToday(workout!, levels)
        : <ExerciseProgressFact>[];
    final improvements = _improvements(levels);
    final difficultyTrend = _difficultyTrend(todayPct, previousPct);
    final monthly = _monthlyStatsIfDue(
      profile: profile,
      completed: completed,
      levels: levels,
      today: today,
    );

    final scenario = _pickScenario(
      doneToday: doneToday,
      totalCompleted: completed.length,
      streak: streak.currentStreak,
      missedYesterday: missedYesterday,
      todayPct: todayPct,
      prsToday: prsToday,
      improvements: improvements,
      monthly: monthly,
    );

    final facts = <String>[
      // Name/injuries are filtered out unless the user opts into private AI.
      'Name: ${profile.name}',
      'Activity level: ${profile.activityLevel.label}',
      'Injuries: ${profile.injuries.map((i) => i.label).join(', ')}',
      'Current streak: ${streak.currentStreak}',
      'Longest streak: ${streak.longestStreak}',
      'Total completed workouts: ${completed.length}',
      'Today completed: $doneToday',
      if (todayPct != null)
        'Today completion: ${(todayPct * 100).round()}%',
      if (previousPct != null)
        'Previous workout completion: ${(previousPct * 100).round()}%',
      if (weekPct != null)
        'Last 7 days avg completion: ${(weekPct * 100).round()}%',
      'Missed yesterday: $missedYesterday',
      'Difficulty trend: $difficultyTrend',
      if (workout != null) ...[
        'Today\'s exercises:',
        ...workout.exercises.map((e) {
          final def = ExerciseLibrary.byId(e.exerciseId);
          final status = e.completed == null
              ? 'pending'
              : 'did ${def.unit.format(e.completed!)} / target ${def.unit.format(e.target)}';
          return '  - ${def.name}: $status';
        }),
      ],
      if (previous != null) ...[
        'Previous workout (${_fmtDate(previous.date)}):',
        ...previous.exercises.map((e) {
          final def = ExerciseLibrary.byId(e.exerciseId);
          return '  - ${def.name}: ${e.completed == null ? 'n/a' : def.unit.format(e.completed!)} / ${def.unit.format(e.target)}';
        }),
      ],
      if (prsToday.isNotEmpty) ...[
        'Personal records today:',
        ...prsToday.map((p) => '  - ${p.name}: ${p.unit.format(p.to)}'),
      ],
      if (improvements.isNotEmpty) ...[
        'Improvements vs first logged performance:',
        ...improvements.take(5).map((p) => '  - ${p.formatted}'),
      ],
      if (monthly != null) ...[
        'Monthly summary due:',
        '  Workouts this month: ${monthly.workoutsCompleted}',
        '  Longest streak in period: ${monthly.longestStreakInPeriod}',
        ...monthly.improvements.take(5).map((p) => '  - ${p.formatted}'),
      ],
    ];

    return CoachInsights(
      scenario: scenario,
      profile: profile,
      streak: streak,
      workout: workout,
      totalCompletedWorkouts: completed.length,
      todayCompletionPercent: todayPct,
      previousWorkoutCompletionPercent: previousPct,
      weekCompletionPercent: weekPct,
      missedYesterday: missedYesterday,
      personalRecordsToday: prsToday,
      improvements: improvements,
      difficultyTrend: difficultyTrend,
      monthlyStats: monthly,
      factsForPrompt: facts,
    );
  }

  static CoachScenario _pickScenario({
    required bool doneToday,
    required int totalCompleted,
    required int streak,
    required bool missedYesterday,
    required double? todayPct,
    required List<ExerciseProgressFact> prsToday,
    required List<ExerciseProgressFact> improvements,
    required MonthlyCoachStats? monthly,
  }) {
    if (monthly != null && doneToday) {
      return CoachScenario.monthlySummary;
    }
    if (doneToday && totalCompleted <= 1) {
      return CoachScenario.firstWorkout;
    }
    if (!doneToday && missedYesterday) {
      return CoachScenario.missedDay;
    }
    if (doneToday && prsToday.isNotEmpty) {
      return CoachScenario.personalRecord;
    }
    if (doneToday && todayPct != null && todayPct < 0.8) {
      return CoachScenario.workoutDifficult;
    }
    if (doneToday && todayPct != null && todayPct >= 1.0) {
      return CoachScenario.workoutEasy;
    }
    if (doneToday && streak >= 30) {
      return CoachScenario.longStreak;
    }
    if (doneToday && streak == 7) {
      return CoachScenario.weekStreak;
    }
    if (doneToday && improvements.isNotEmpty) {
      return CoachScenario.improvement;
    }
    if (doneToday) {
      return CoachScenario.afterWorkout;
    }
    return CoachScenario.beforeWorkout;
  }

  static double? _completionPercent(DailyWorkout? workout) {
    if (workout == null || workout.exercises.isEmpty) return null;
    final withData = workout.exercises.where((e) => e.completed != null);
    if (withData.isEmpty) return null;
    var sum = 0.0;
    var n = 0;
    for (final e in withData) {
      if (e.target <= 0) continue;
      sum += (e.completed! / e.target).clamp(0.0, 1.5);
      n += 1;
    }
    if (n == 0) return null;
    return sum / n;
  }

  static DailyWorkout? _previousCompleted(
    List<DailyWorkout> completed,
    DateTime today,
  ) {
    for (var i = completed.length - 1; i >= 0; i--) {
      if (!StreakService.isSameDay(completed[i].date, today)) {
        return completed[i];
      }
    }
    return null;
  }

  static double? _weekCompletionPercent(
    List<DailyWorkout> completed,
    DateTime today,
  ) {
    final start = today.subtract(const Duration(days: 7));
    final recent = completed
        .where((w) => !w.date.isBefore(start) && !w.date.isAfter(today))
        .toList();
    if (recent.isEmpty) return null;
    final values = recent.map(_completionPercent).whereType<double>().toList();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  static bool _missedYesterday(
    StreakState streak,
    DateTime today,
    List<DailyWorkout> completed,
  ) {
    if (streak.currentStreak > 0) return false;
    if (completed.isEmpty) return false;
    final last = streak.lastCompletedDate ?? completed.last.date;
    final gap = StreakService.daysBetween(last, today);
    return gap >= 2;
  }

  static List<ExerciseProgressFact> _personalRecordsToday(
    DailyWorkout workout,
    Map<String, ExerciseLevel> levels,
  ) {
    final facts = <ExerciseProgressFact>[];
    for (final e in workout.exercises) {
      final completed = e.completed;
      if (completed == null || completed <= 0) continue;
      final level = levels[e.exerciseId];
      if (level == null) continue;

      final priorBest = level.history.length <= 1
          ? 0
          : level.history
              .sublist(0, level.history.length - 1)
              .map((h) => h.completed)
              .reduce((a, b) => a > b ? a : b);

      if (completed <= priorBest) continue;
      if (completed < level.personalBest) continue;

      final def = ExerciseLibrary.byId(e.exerciseId);
      facts.add(
        ExerciseProgressFact(
          exerciseId: e.exerciseId,
          name: def.name,
          from: priorBest,
          to: completed,
          unit: def.unit,
          percentGain: priorBest <= 0
              ? 100
              : (((completed - priorBest) / priorBest) * 100).round(),
          isPersonalRecord: true,
        ),
      );
    }
    return facts;
  }

  static List<ExerciseProgressFact> _improvements(
    Map<String, ExerciseLevel> levels,
  ) {
    final facts = <ExerciseProgressFact>[];
    for (final level in levels.values) {
      if (level.history.length < 2) continue;
      final first = level.history.first.completed;
      final latest = level.history.last.completed;
      if (latest <= first || first <= 0) continue;
      final def = ExerciseLibrary.byId(level.exerciseId);
      final gain = (((latest - first) / first) * 100).round();
      if (gain < 15) continue;
      facts.add(
        ExerciseProgressFact(
          exerciseId: level.exerciseId,
          name: def.name,
          from: first,
          to: latest,
          unit: def.unit,
          percentGain: gain,
          isPersonalRecord: latest >= level.personalBest,
        ),
      );
    }
    facts.sort((a, b) => b.percentGain.compareTo(a.percentGain));
    return facts;
  }

  static String _difficultyTrend(double? today, double? previous) {
    if (today == null) return 'unknown';
    if (previous == null) {
      if (today >= 1.0) return 'comfortable';
      if (today < 0.8) return 'challenging';
      return 'steady';
    }
    if (today < 0.8) return 'harder than usual';
    if (today >= 1.0 && previous >= 0.95) return 'comfortable — ready for slight increase';
    if (today >= previous + 0.15) return 'easier than previous session';
    if (today <= previous - 0.15) return 'tougher than previous session';
    return 'steady';
  }

  static MonthlyCoachStats? _monthlyStatsIfDue({
    required UserProfile profile,
    required List<DailyWorkout> completed,
    required Map<String, ExerciseLevel> levels,
    required DateTime today,
  }) {
    final start = profile.createdAt ??
        (completed.isEmpty ? null : completed.first.date);
    if (start == null) return null;
    final startDay = StreakService.dateOnly(start);
    final days = StreakService.daysBetween(startDay, today);
    if (days <= 0 || days % 30 != 0) return null;

    final windowStart = today.subtract(const Duration(days: 30));
    final inWindow = completed
        .where((w) => !w.date.isBefore(windowStart) && !w.date.isAfter(today))
        .toList();

    return MonthlyCoachStats(
      workoutsCompleted: inWindow.length,
      longestStreakInPeriod: profile.createdAt != null
          ? _estimateLongestInWindow(inWindow)
          : inWindow.length,
      improvements: _improvements(levels),
    );
  }

  static int _estimateLongestInWindow(List<DailyWorkout> workouts) {
    if (workouts.isEmpty) return 0;
    final days = workouts.map((w) => StreakService.dateOnly(w.date)).toList()
      ..sort();
    var best = 1;
    var run = 1;
    for (var i = 1; i < days.length; i++) {
      final gap = StreakService.daysBetween(days[i - 1], days[i]);
      if (gap == 1) {
        run += 1;
        if (run > best) best = run;
      } else if (gap > 1) {
        run = 1;
      }
    }
    return best;
  }

  static String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
