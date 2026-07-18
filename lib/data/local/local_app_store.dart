import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/exercise_level.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/workout.dart';

class LocalStorageKeys {
  static const profile = 'mf_profile';
  static const levels = 'mf_levels';
  static const workouts = 'mf_workouts';
  static const streak = 'mf_streak';
  static const assessment = 'mf_assessment';
}

class LocalAppStore {
  LocalAppStore(this._prefs);

  final SharedPreferences _prefs;

  UserProfile? readProfile() {
    final raw = _prefs.getString(LocalStorageKeys.profile);
    if (raw == null) return null;
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> writeProfile(UserProfile profile) async {
    await _prefs.setString(
      LocalStorageKeys.profile,
      jsonEncode(profile.toJson()),
    );
  }

  Map<String, ExerciseLevel> readLevels() {
    final raw = _prefs.getString(LocalStorageKeys.levels);
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return {
      for (final entry in map.entries)
        entry.key: ExerciseLevel.fromJson(entry.value as Map<String, dynamic>),
    };
  }

  Future<void> writeLevels(Map<String, ExerciseLevel> levels) async {
    final encoded = {
      for (final e in levels.entries) e.key: e.value.toJson(),
    };
    await _prefs.setString(LocalStorageKeys.levels, jsonEncode(encoded));
  }

  List<DailyWorkout> readWorkouts() {
    final raw = _prefs.getString(LocalStorageKeys.workouts);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return [
      for (final w in list)
        DailyWorkout.fromJson(w as Map<String, dynamic>),
    ];
  }

  Future<void> writeWorkouts(List<DailyWorkout> workouts) async {
    // Keep last 90 days.
    final trimmed = workouts.length > 90
        ? workouts.sublist(workouts.length - 90)
        : workouts;
    await _prefs.setString(
      LocalStorageKeys.workouts,
      jsonEncode(trimmed.map((w) => w.toJson()).toList()),
    );
  }

  StreakState readStreak() {
    final raw = _prefs.getString(LocalStorageKeys.streak);
    if (raw == null) return StreakState.empty;
    return StreakState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> writeStreak(StreakState streak) async {
    await _prefs.setString(
      LocalStorageKeys.streak,
      jsonEncode(streak.toJson()),
    );
  }

  Map<String, int> readAssessment() {
    final raw = _prefs.getString(LocalStorageKeys.assessment);
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return {
      for (final e in map.entries) e.key: (e.value as num).toInt(),
    };
  }

  Future<void> writeAssessment(Map<String, int> results) async {
    await _prefs.setString(LocalStorageKeys.assessment, jsonEncode(results));
  }

  Future<void> clearAll() async {
    await _prefs.remove(LocalStorageKeys.profile);
    await _prefs.remove(LocalStorageKeys.levels);
    await _prefs.remove(LocalStorageKeys.workouts);
    await _prefs.remove(LocalStorageKeys.streak);
    await _prefs.remove(LocalStorageKeys.assessment);
  }
}
