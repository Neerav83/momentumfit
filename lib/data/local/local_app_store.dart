import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/exercise_level.dart';
import '../../domain/models/reminder_settings.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/workout.dart';
import 'app_database.dart';

class LocalStorageKeys {
  static const profile = 'mf_profile';
  static const levels = 'mf_levels';
  static const workouts = 'mf_workouts';
  static const streak = 'mf_streak';
  static const assessment = 'mf_assessment';
  static const migrated = 'mf_migrated_to_sqlite';
  static const coachDate = 'mf_coach_date';
  static const coachText = 'mf_coach_text';
  static const coachDoneKey = 'mf_coach_done_key';
  static const reminder = 'mf_reminder';
}

class LocalAppStore {
  LocalAppStore(this._prefs) : _useDatabase = true;

  /// In-memory store for widget/unit tests (no SQLite).
  LocalAppStore.forTesting(this._prefs) : _useDatabase = false;

  final SharedPreferences _prefs;
  final bool _useDatabase;
  final _db = AppDatabase.instance;
  bool _initialized = false;

  // In-memory cache
  UserProfile? _profile;
  Map<String, ExerciseLevel>? _levels;
  List<DailyWorkout>? _workouts;
  StreakState? _streak;
  Map<String, int>? _assessment;

  Future<void> initialize() async {
    if (_initialized) return;

    if (_useDatabase) {
      await _migrateToSqlite();
      await _loadFromDatabase();
    }

    _initialized = true;
  }

  Future<void> _migrateToSqlite() async {
    final alreadyMigrated = _prefs.getBool(LocalStorageKeys.migrated) ?? false;
    if (alreadyMigrated) return;

    // Migrate profile
    final profileRaw = _prefs.getString(LocalStorageKeys.profile);
    if (profileRaw != null) {
      try {
        final profile =
            UserProfile.fromJson(jsonDecode(profileRaw) as Map<String, dynamic>);
        await _db.saveProfile(profile);
      } catch (e) {
        // Migration failed, continue anyway
      }
    }

    // Migrate levels
    final levelsRaw = _prefs.getString(LocalStorageKeys.levels);
    if (levelsRaw != null) {
      try {
        final map = jsonDecode(levelsRaw) as Map<String, dynamic>;
        final levels = {
          for (final entry in map.entries)
            entry.key:
                ExerciseLevel.fromJson(entry.value as Map<String, dynamic>),
        };
        await _db.saveLevels(levels);
      } catch (e) {
        // Migration failed, continue anyway
      }
    }

    // Migrate workouts
    final workoutsRaw = _prefs.getString(LocalStorageKeys.workouts);
    if (workoutsRaw != null) {
      try {
        final list = jsonDecode(workoutsRaw) as List<dynamic>;
        final workouts = [
          for (final w in list)
            DailyWorkout.fromJson(w as Map<String, dynamic>),
        ];
        await _db.saveWorkouts(workouts);
      } catch (e) {
        // Migration failed, continue anyway
      }
    }

    // Migrate streak
    final streakRaw = _prefs.getString(LocalStorageKeys.streak);
    if (streakRaw != null) {
      try {
        final streak =
            StreakState.fromJson(jsonDecode(streakRaw) as Map<String, dynamic>);
        await _db.saveStreak(streak);
      } catch (e) {
        // Migration failed, continue anyway
      }
    }

    // Migrate assessment
    final assessmentRaw = _prefs.getString(LocalStorageKeys.assessment);
    if (assessmentRaw != null) {
      try {
        final map = jsonDecode(assessmentRaw) as Map<String, dynamic>;
        final assessment = {
          for (final e in map.entries) e.key: (e.value as num).toInt(),
        };
        await _db.saveAssessment(assessment);
      } catch (e) {
        // Migration failed, continue anyway
      }
    }

    // Mark as migrated
    await _prefs.setBool(LocalStorageKeys.migrated, true);

    // Clean up old SharedPreferences data
    await _prefs.remove(LocalStorageKeys.profile);
    await _prefs.remove(LocalStorageKeys.levels);
    await _prefs.remove(LocalStorageKeys.workouts);
    await _prefs.remove(LocalStorageKeys.streak);
    await _prefs.remove(LocalStorageKeys.assessment);
  }

  Future<void> _loadFromDatabase() async {
    _profile = await _db.getProfile();
    _levels = await _db.getLevels();
    _workouts = await _db.getWorkouts();
    _streak = await _db.getStreak();
    _assessment = await _db.getAssessment();
  }

  UserProfile? readProfile() => _profile;

  Future<void> writeProfile(UserProfile profile) async {
    _profile = profile;
    if (_useDatabase) await _db.saveProfile(profile);
  }

  Map<String, ExerciseLevel> readLevels() => _levels ?? {};

  Future<void> writeLevels(Map<String, ExerciseLevel> levels) async {
    _levels = levels;
    if (_useDatabase) await _db.saveLevels(levels);
  }

  List<DailyWorkout> readWorkouts() => _workouts ?? [];

  Future<void> writeWorkouts(List<DailyWorkout> workouts) async {
    // Keep last 90 days
    final trimmed =
        workouts.length > 90 ? workouts.sublist(workouts.length - 90) : workouts;
    _workouts = trimmed;
    if (_useDatabase) await _db.saveWorkouts(trimmed);
  }

  StreakState readStreak() => _streak ?? StreakState.empty;

  Future<void> writeStreak(StreakState streak) async {
    _streak = streak;
    if (_useDatabase) await _db.saveStreak(streak);
  }

  Map<String, int> readAssessment() => _assessment ?? {};

  Future<void> writeAssessment(Map<String, int> results) async {
    _assessment = results;
    if (_useDatabase) await _db.saveAssessment(results);
  }

  /// Cached coach nudge: one text per calendar day + workout-done state.
  String? readCoachNudge({required String dateKey, required bool workoutDone}) {
    final cachedDate = _prefs.getString(LocalStorageKeys.coachDate);
    final cachedDone = _prefs.getBool(LocalStorageKeys.coachDoneKey) ?? false;
    if (cachedDate != dateKey || cachedDone != workoutDone) return null;
    return _prefs.getString(LocalStorageKeys.coachText);
  }

  Future<void> writeCoachNudge({
    required String dateKey,
    required bool workoutDone,
    required String text,
  }) async {
    await _prefs.setString(LocalStorageKeys.coachDate, dateKey);
    await _prefs.setBool(LocalStorageKeys.coachDoneKey, workoutDone);
    await _prefs.setString(LocalStorageKeys.coachText, text);
  }

  Future<void> clearCoachNudge() async {
    await _prefs.remove(LocalStorageKeys.coachDate);
    await _prefs.remove(LocalStorageKeys.coachDoneKey);
    await _prefs.remove(LocalStorageKeys.coachText);
  }

  ReminderSettings readReminderSettings() {
    final raw = _prefs.getString(LocalStorageKeys.reminder);
    if (raw == null) return ReminderSettings.defaults;
    try {
      return ReminderSettings.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return ReminderSettings.defaults;
    }
  }

  Future<void> writeReminderSettings(ReminderSettings settings) async {
    await _prefs.setString(
      LocalStorageKeys.reminder,
      jsonEncode(settings.toJson()),
    );
  }

  Future<void> clearAll() async {
    _profile = null;
    _levels = null;
    _workouts = null;
    _streak = null;
    _assessment = null;
    await clearCoachNudge();
    await _prefs.remove(LocalStorageKeys.reminder);
    if (_useDatabase) await _db.clearAll();
  }
}
