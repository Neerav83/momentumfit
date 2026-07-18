import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local/local_app_store.dart';
import '../data/repositories/momentum_repository.dart';
import '../domain/models/exercise_level.dart';
import '../domain/models/user_profile.dart';
import '../domain/models/workout.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main()');
});

final localAppStoreProvider = Provider<LocalAppStore>((ref) {
  return LocalAppStore(ref.watch(sharedPreferencesProvider));
});

final momentumRepositoryProvider = Provider<MomentumRepository>((ref) {
  return MomentumRepository(ref.watch(localAppStoreProvider));
});

final profileProvider =
    NotifierProvider<ProfileNotifier, UserProfile?>(ProfileNotifier.new);

class ProfileNotifier extends Notifier<UserProfile?> {
  @override
  UserProfile? build() {
    return ref.read(momentumRepositoryProvider).getProfile();
  }

  Future<void> save(UserProfile profile) async {
    await ref.read(momentumRepositoryProvider).saveProfile(profile);
    state = profile;
  }

  Future<void> completeOnboarding(UserProfile profile) async {
    await ref.read(momentumRepositoryProvider).completeOnboarding(profile);
    state = ref.read(momentumRepositoryProvider).getProfile();
  }

  Future<void> completeAssessment(Map<String, int> results) async {
    final profile = state;
    if (profile == null) return;

    final repo = ref.read(momentumRepositoryProvider);
    await repo.completeAssessment(profile: profile, results: results);

    // Refresh data that does not watch profile, before notifying listeners.
    ref.read(levelsProvider.notifier).refresh();

    // Defer profile update so GoRouter/Home don't rebuild mid-notification
    // (avoids CircularDependencyError).
    final updated = repo.getProfile();
    await Future<void>.delayed(Duration.zero);
    state = updated;
  }

  Future<void> reset() async {
    await ref.read(momentumRepositoryProvider).resetAll();
    state = null;
    ref.read(levelsProvider.notifier).refresh();
    ref.read(streakProvider.notifier).refresh();
  }
}

final levelsProvider =
    NotifierProvider<LevelsNotifier, Map<String, ExerciseLevel>>(
  LevelsNotifier.new,
);

class LevelsNotifier extends Notifier<Map<String, ExerciseLevel>> {
  @override
  Map<String, ExerciseLevel> build() {
    return ref.read(momentumRepositoryProvider).getLevels();
  }

  void refresh() {
    state = ref.read(momentumRepositoryProvider).getLevels();
  }
}

final streakProvider =
    NotifierProvider<StreakNotifier, StreakState>(StreakNotifier.new);

class StreakNotifier extends Notifier<StreakState> {
  @override
  StreakState build() {
    return ref.read(momentumRepositoryProvider).getStreak();
  }

  void set(StreakState streak) => state = streak;

  void refresh() {
    final streak = ref.read(momentumRepositoryProvider).getStreak();
    ref.read(momentumRepositoryProvider).persistStreak(streak);
    state = streak;
  }
}

final assessmentResultsProvider = Provider<Map<String, int>>((ref) {
  // Rebuild when profile changes (e.g. after assessment).
  ref.watch(profileProvider);
  return ref.read(momentumRepositoryProvider).getAssessment();
});

final workoutHistoryProvider = Provider<List<DailyWorkout>>((ref) {
  ref.watch(profileProvider);
  ref.watch(levelsProvider);
  return ref.read(momentumRepositoryProvider).getWorkouts();
});

final todaysWorkoutProvider =
    AsyncNotifierProvider<TodaysWorkoutNotifier, DailyWorkout?>(
  TodaysWorkoutNotifier.new,
);

class TodaysWorkoutNotifier extends AsyncNotifier<DailyWorkout?> {
  @override
  Future<DailyWorkout?> build() async {
    final profile = ref.watch(profileProvider);
    if (profile == null || !profile.assessmentCompleted) return null;
    return ref.read(momentumRepositoryProvider).ensureTodaysWorkout(
          profile: profile,
        );
  }

  Future<void> markExercise({
    required int index,
    required int completed,
  }) async {
    final current = state.asData?.value;
    if (current == null) return;
    final updated =
        await ref.read(momentumRepositoryProvider).updateExerciseProgress(
              workout: current,
              exerciseIndex: index,
              completed: completed,
            );
    state = AsyncData(updated);
  }

  Future<void> finishWorkout() async {
    final current = state.asData?.value;
    if (current == null || !current.allMarked) return;
    final result = await ref.read(momentumRepositoryProvider).completeWorkout(
          workout: current,
        );
    state = AsyncData(result.workout);
    ref.read(streakProvider.notifier).set(result.streak);
    ref.read(levelsProvider.notifier).refresh();
  }
}
