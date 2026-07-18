import '../models/enums.dart';
import '../models/exercise.dart';
import '../models/exercise_level.dart';
import '../models/user_profile.dart';
import '../models/workout.dart';

/// Slow, forgiving adaptation — consistency over intensity.
abstract final class AdaptiveDifficulty {
  static const successSessionsNeeded = 2;
  static const failSessionsNeeded = 2;

  static int initialTarget({
    required ExerciseDefinition exercise,
    required int assessmentResult,
    required ActivityLevel activityLevel,
  }) {
    final safeResult = assessmentResult < 0 ? 0 : assessmentResult;
    final raw = (safeResult * activityLevel.startMultiplier).round();
    final min = exercise.unit == ExerciseUnit.seconds ? 8 : 2;
    // clamp() throws if lower > upper — common when assessment is very low.
    final max = safeResult < min ? min : safeResult;
    final target = raw.clamp(min, max).toInt();
    return target < 1 ? 1 : target;
  }

  /// Seed related exercises from assessment baselines.
  static Map<String, ExerciseLevel> seedLevels({
    required UserProfile profile,
    required Map<String, int> assessmentResults,
  }) {
    final push = assessmentResults['push_ups'] ?? 8;
    final squat = assessmentResults['squats'] ?? 15;
    final plank = assessmentResults['plank'] ?? 20;

    final seeds = <String, int>{
      'push_ups': push,
      'knee_push_ups': _atLeast(1, (push * 1.4).round()),
      'chair_dips': _atLeast(1, (push * 0.8).round()),
      'squats': squat,
      'lunges': _atLeast(1, (squat * 0.7).round()),
      'glute_bridge': _atLeast(1, (squat * 0.9).round()),
      'calf_raises': _atLeast(1, (squat * 1.1).round()),
      'plank': plank,
      'side_plank': _atLeast(1, (plank * 0.6).round()),
      'dead_bug': _atLeast(1, (plank / 3).round()),
      'bird_dog': _atLeast(1, (plank / 3).round()),
      'jumping_jacks': _atLeast(1, (squat * 1.2).round()),
      'high_knees': _atLeast(1, (squat * 1.0).round()),
      'mountain_climbers': _atLeast(1, (squat * 0.9).round()),
    };

    final levels = <String, ExerciseLevel>{};
    for (final exercise in ExerciseLibrary.availableFor(profile.injuries)) {
      final assessmentLike = seeds[exercise.id] ?? 10;
      final target = initialTarget(
        exercise: exercise,
        assessmentResult: assessmentLike,
        activityLevel: profile.activityLevel,
      );
      levels[exercise.id] = ExerciseLevel(
        exerciseId: exercise.id,
        currentTarget: target,
        successStreak: 0,
        failStreak: 0,
        personalBest: assessmentResults[exercise.id] ?? 0,
        history: [
          LevelHistoryPoint(
            date: DateTime.now(),
            target: target,
            completed: assessmentResults[exercise.id] ?? target,
          ),
        ],
      );
    }
    return levels;
  }

  static int _atLeast(int min, int value) => value < min ? min : value;

  static ExerciseLevel adapt({
    required ExerciseLevel level,
    required int completed,
    required ExerciseUnit unit,
  }) {
    final ratio = level.currentTarget == 0
        ? 1.0
        : completed / level.currentTarget;

    var success = level.successStreak;
    var fail = level.failStreak;
    var target = level.currentTarget;

    if (ratio >= 1.0) {
      success += 1;
      fail = 0;
      if (success >= successSessionsNeeded) {
        target = _bumpUp(target, unit);
        success = 0;
      }
    } else if (ratio >= 0.8) {
      // Stay the same — close enough.
      success = 0;
      fail = 0;
    } else {
      success = 0;
      fail += 1;
      if (fail >= failSessionsNeeded) {
        target = _bumpDown(target, unit);
        fail = 0;
      }
    }

    final history = [
      ...level.history,
      LevelHistoryPoint(
        date: DateTime.now(),
        target: level.currentTarget,
        completed: completed,
      ),
    ];

    return level.copyWith(
      currentTarget: target,
      successStreak: success,
      failStreak: fail,
      personalBest: completed > level.personalBest ? completed : level.personalBest,
      history: history.length > 60 ? history.sublist(history.length - 60) : history,
    );
  }

  static int _bumpUp(int target, ExerciseUnit unit) {
    if (unit == ExerciseUnit.seconds) {
      return target + (target < 30 ? 3 : 5);
    }
    if (target < 10) return target + 1;
    if (target < 20) return target + 2;
    return target + 3;
  }

  static int _bumpDown(int target, ExerciseUnit unit) {
    final min = unit == ExerciseUnit.seconds ? 8 : 2;
    if (unit == ExerciseUnit.seconds) {
      return (target - 3).clamp(min, target);
    }
    final step = target < 10 ? 1 : 2;
    return (target - step).clamp(min, target);
  }

  /// Build today's workout: 3–5 exercises across categories.
  static DailyWorkout buildDailyWorkout({
    required String id,
    required DateTime date,
    required UserProfile profile,
    required Map<String, ExerciseLevel> levels,
    required int dayIndex,
  }) {
    final available = ExerciseLibrary.availableFor(profile.injuries);
    final byCategory = <ExerciseCategory, List<ExerciseDefinition>>{};
    for (final e in available) {
      byCategory.putIfAbsent(e.category, () => []).add(e);
    }

    final categories = ExerciseCategory.values
        .where((c) => byCategory[c]?.isNotEmpty ?? false)
        .toList();

    // Rotate starting category by day for variety.
    final ordered = [
      ...categories.skip(dayIndex % categories.length),
      ...categories.take(dayIndex % categories.length),
    ];

    final picked = <ExerciseDefinition>[];
    for (final category in ordered) {
      final pool = byCategory[category]!;
      final pick = pool[dayIndex % pool.length];
      if (!picked.any((e) => e.id == pick.id)) {
        picked.add(pick);
      }
      if (picked.length >= 4) break;
    }

    // Always include at least one assessment move if available.
    for (final core in ExerciseLibrary.assessmentExercises) {
      if (available.any((e) => e.id == core.id) &&
          !picked.any((e) => e.id == core.id) &&
          picked.length < 5) {
        picked.insert(0, core);
        break;
      }
    }

    final exercises = picked.take(5).map((def) {
      final level = levels[def.id];
      return WorkoutExercise(
        exerciseId: def.id,
        target: level?.currentTarget ?? 5,
      );
    }).toList();

    return DailyWorkout(
      id: id,
      date: DateTime(date.year, date.month, date.day),
      exercises: exercises,
    );
  }
}
