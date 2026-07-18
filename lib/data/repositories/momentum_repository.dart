import 'package:uuid/uuid.dart';

import '../../domain/models/exercise.dart';
import '../../domain/models/exercise_level.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/workout.dart';
import '../../domain/services/adaptive_difficulty.dart';
import '../../domain/services/streak_service.dart';
import '../local/local_app_store.dart';

class MomentumRepository {
  MomentumRepository(this._store);

  final LocalAppStore _store;
  static const _uuid = Uuid();

  UserProfile? getProfile() => _store.readProfile();

  Future<void> saveProfile(UserProfile profile) => _store.writeProfile(profile);

  Map<String, ExerciseLevel> getLevels() => _store.readLevels();

  StreakState getStreak() {
    return StreakService.evaluateMissedDays(
      current: _store.readStreak(),
      now: DateTime.now(),
    );
  }

  Future<void> persistStreak(StreakState streak) => _store.writeStreak(streak);

  List<DailyWorkout> getWorkouts() => _store.readWorkouts();

  Map<String, int> getAssessment() => _store.readAssessment();

  Future<void> completeOnboarding(UserProfile profile) async {
    await saveProfile(
      profile.copyWith(
        onboardingCompleted: true,
        createdAt: profile.createdAt ?? DateTime.now(),
      ),
    );
  }

  Future<void> completeAssessment({
    required UserProfile profile,
    required Map<String, int> results,
  }) async {
    final levels = AdaptiveDifficulty.seedLevels(
      profile: profile,
      assessmentResults: results,
    );
    await _store.writeAssessment(results);
    await _store.writeLevels(levels);
    await saveProfile(
      profile.copyWith(
        assessmentCompleted: true,
        lastAssessmentAt: DateTime.now(),
      ),
    );
  }

  Future<DailyWorkout> ensureTodaysWorkout({
    required UserProfile profile,
  }) async {
    final workouts = _store.readWorkouts();
    final today = StreakService.dateOnly(DateTime.now());
    final existingIndex = workouts.indexWhere(
      (w) => StreakService.isSameDay(w.date, today),
    );
    if (existingIndex >= 0) return workouts[existingIndex];

    final levels = _store.readLevels();
    final workout = AdaptiveDifficulty.buildDailyWorkout(
      id: _uuid.v4(),
      date: today,
      profile: profile,
      levels: levels,
      dayIndex: workouts.length,
    );
    await _store.writeWorkouts([...workouts, workout]);
    return workout;
  }

  Future<DailyWorkout> updateExerciseProgress({
    required DailyWorkout workout,
    required int exerciseIndex,
    required int completed,
  }) async {
    final exercises = [...workout.exercises];
    exercises[exerciseIndex] = exercises[exerciseIndex].copyWith(
      completed: completed,
      done: true,
    );
    final updated = workout.copyWith(exercises: exercises);
    await _replaceWorkout(updated);
    return updated;
  }

  Future<({DailyWorkout workout, StreakState streak})> completeWorkout({
    required DailyWorkout workout,
  }) async {
    final now = DateTime.now();
    final completed = workout.copyWith(completedAt: now);

    final levels = Map<String, ExerciseLevel>.from(_store.readLevels());
    for (final item in completed.exercises) {
      final current = levels[item.exerciseId];
      if (current == null || item.completed == null) continue;
      levels[item.exerciseId] = AdaptiveDifficulty.adapt(
        level: current,
        completed: item.completed!,
        unit: ExerciseLibrary.byId(item.exerciseId).unit,
      );
    }
    await _store.writeLevels(levels);
    await _replaceWorkout(completed);

    final streak = StreakService.onWorkoutCompleted(
      current: getStreak(),
      completedAt: now,
    );
    await _store.writeStreak(streak);

    return (workout: completed, streak: streak);
  }

  Future<void> _replaceWorkout(DailyWorkout workout) async {
    final workouts = [..._store.readWorkouts()];
    final index = workouts.indexWhere((w) => w.id == workout.id);
    if (index >= 0) {
      workouts[index] = workout;
    } else {
      workouts.add(workout);
    }
    await _store.writeWorkouts(workouts);
  }

  Future<void> resetAll() => _store.clearAll();
}
