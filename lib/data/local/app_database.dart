import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/models/exercise_level.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/workout.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'momentumfit.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        name TEXT NOT NULL,
        avatar_id TEXT NOT NULL,
        age INTEGER NOT NULL,
        height_cm INTEGER NOT NULL,
        weight_kg REAL NOT NULL,
        activity_level TEXT NOT NULL,
        injuries TEXT NOT NULL,
        onboarding_completed INTEGER NOT NULL DEFAULT 0,
        assessment_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT,
        last_assessment_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE exercise_levels (
        exercise_id TEXT PRIMARY KEY,
        current_target INTEGER NOT NULL,
        success_streak INTEGER NOT NULL DEFAULT 0,
        fail_streak INTEGER NOT NULL DEFAULT 0,
        personal_best INTEGER NOT NULL DEFAULT 0,
        history_json TEXT NOT NULL DEFAULT '[]'
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_workouts (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        completed_at TEXT,
        UNIQUE(date)
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id TEXT NOT NULL,
        exercise_id TEXT NOT NULL,
        target INTEGER NOT NULL,
        completed INTEGER,
        done INTEGER NOT NULL DEFAULT 0,
        position INTEGER NOT NULL,
        FOREIGN KEY (workout_id) REFERENCES daily_workouts (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE streak_state (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        current_streak INTEGER NOT NULL DEFAULT 0,
        longest_streak INTEGER NOT NULL DEFAULT 0,
        last_completed_date TEXT,
        freeze_count INTEGER NOT NULL DEFAULT 0,
        last_freeze_earned_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE assessment_results (
        exercise_id TEXT PRIMARY KEY,
        reps INTEGER NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_workout_exercises_workout_id ON workout_exercises(workout_id)',
    );
    await db.execute(
      'CREATE INDEX idx_daily_workouts_date ON daily_workouts(date)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Schema was incorrect in v1 — recreate to match domain models.
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS user_profile');
      await db.execute('DROP TABLE IF EXISTS exercise_levels');
      await db.execute('DROP TABLE IF EXISTS daily_workouts');
      await db.execute('DROP TABLE IF EXISTS workout_exercises');
      await db.execute('DROP TABLE IF EXISTS streak_state');
      await db.execute('DROP TABLE IF EXISTS assessment_results');
      await _onCreate(db, newVersion);
    }
  }

  Future<UserProfile?> getProfile() async {
    final db = await database;
    final maps = await db.query('user_profile', limit: 1);
    if (maps.isEmpty) return null;

    final map = maps.first;
    final injuriesRaw = map['injuries'] as String? ?? '["none"]';
    final injuriesList = jsonDecode(injuriesRaw) as List<dynamic>;

    return UserProfile.fromJson({
      'name': map['name'],
      'avatarId': map['avatar_id'],
      'age': map['age'],
      'heightCm': map['height_cm'],
      'weightKg': map['weight_kg'],
      'activityLevel': map['activity_level'],
      'injuries': injuriesList,
      'onboardingCompleted': map['onboarding_completed'] == 1,
      'assessmentCompleted': map['assessment_completed'] == 1,
      'createdAt': map['created_at'],
      'lastAssessmentAt': map['last_assessment_at'],
    });
  }

  Future<void> saveProfile(UserProfile profile) async {
    final db = await database;
    await db.insert(
      'user_profile',
      {
        'id': 1,
        'name': profile.name,
        'avatar_id': profile.avatarId,
        'age': profile.age,
        'height_cm': profile.heightCm,
        'weight_kg': profile.weightKg,
        'activity_level': profile.activityLevel.name,
        'injuries': jsonEncode(profile.injuries.map((e) => e.name).toList()),
        'onboarding_completed': profile.onboardingCompleted ? 1 : 0,
        'assessment_completed': profile.assessmentCompleted ? 1 : 0,
        'created_at': profile.createdAt?.toIso8601String(),
        'last_assessment_at': profile.lastAssessmentAt?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, ExerciseLevel>> getLevels() async {
    final db = await database;
    final maps = await db.query('exercise_levels');

    return {
      for (final map in maps)
        map['exercise_id'] as String: ExerciseLevel(
          exerciseId: map['exercise_id'] as String,
          currentTarget: map['current_target'] as int,
          successStreak: map['success_streak'] as int? ?? 0,
          failStreak: map['fail_streak'] as int? ?? 0,
          personalBest: map['personal_best'] as int? ?? 0,
          history: _decodeHistory(map['history_json'] as String?),
        ),
    };
  }

  Future<void> saveLevels(Map<String, ExerciseLevel> levels) async {
    final db = await database;
    final batch = db.batch();

    for (final entry in levels.entries) {
      final level = entry.value;
      batch.insert(
        'exercise_levels',
        {
          'exercise_id': entry.key,
          'current_target': level.currentTarget,
          'success_streak': level.successStreak,
          'fail_streak': level.failStreak,
          'personal_best': level.personalBest,
          'history_json': jsonEncode(
            level.history.map((h) => h.toJson()).toList(),
          ),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  List<LevelHistoryPoint> _decodeHistory(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return [
        for (final item in list)
          LevelHistoryPoint.fromJson(item as Map<String, dynamic>),
      ];
    } catch (_) {
      return const [];
    }
  }

  Future<List<DailyWorkout>> getWorkouts() async {
    final db = await database;
    final workoutMaps = await db.query(
      'daily_workouts',
      orderBy: 'date ASC',
    );

    final workouts = <DailyWorkout>[];
    for (final workoutMap in workoutMaps) {
      final workoutId = workoutMap['id'] as String;
      final exerciseMaps = await db.query(
        'workout_exercises',
        where: 'workout_id = ?',
        whereArgs: [workoutId],
        orderBy: 'position ASC',
      );

      final exercises = exerciseMaps.map((map) {
        return WorkoutExercise(
          exerciseId: map['exercise_id'] as String,
          target: map['target'] as int,
          completed: map['completed'] as int?,
          done: map['done'] == 1,
        );
      }).toList();

      workouts.add(
        DailyWorkout(
          id: workoutId,
          date: DateTime.parse(workoutMap['date'] as String),
          exercises: exercises,
          completedAt: workoutMap['completed_at'] != null
              ? DateTime.tryParse(workoutMap['completed_at'] as String)
              : null,
        ),
      );
    }

    return workouts;
  }

  Future<void> saveWorkouts(List<DailyWorkout> workouts) async {
    final db = await database;
    final batch = db.batch();

    batch.delete('workout_exercises');
    batch.delete('daily_workouts');

    for (final workout in workouts) {
      batch.insert(
        'daily_workouts',
        {
          'id': workout.id,
          'date': workout.date.toIso8601String(),
          'completed_at': workout.completedAt?.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (var i = 0; i < workout.exercises.length; i++) {
        final exercise = workout.exercises[i];
        batch.insert(
          'workout_exercises',
          {
            'workout_id': workout.id,
            'exercise_id': exercise.exerciseId,
            'target': exercise.target,
            'completed': exercise.completed,
            'done': exercise.done ? 1 : 0,
            'position': i,
          },
        );
      }
    }

    await batch.commit(noResult: true);
  }

  Future<StreakState> getStreak() async {
    final db = await database;
    final maps = await db.query('streak_state', limit: 1);
    if (maps.isEmpty) return StreakState.empty;

    final map = maps.first;
    return StreakState(
      currentStreak: map['current_streak'] as int? ?? 0,
      longestStreak: map['longest_streak'] as int? ?? 0,
      lastCompletedDate: map['last_completed_date'] != null
          ? DateTime.tryParse(map['last_completed_date'] as String)
          : null,
      freezeCount: map['freeze_count'] as int? ?? 0,
      lastFreezeEarnedAt: map['last_freeze_earned_at'] != null
          ? DateTime.tryParse(map['last_freeze_earned_at'] as String)
          : null,
    );
  }

  Future<void> saveStreak(StreakState streak) async {
    final db = await database;
    await db.insert(
      'streak_state',
      {
        'id': 1,
        'current_streak': streak.currentStreak,
        'longest_streak': streak.longestStreak,
        'last_completed_date': streak.lastCompletedDate?.toIso8601String(),
        'freeze_count': streak.freezeCount,
        'last_freeze_earned_at': streak.lastFreezeEarnedAt?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, int>> getAssessment() async {
    final db = await database;
    final maps = await db.query('assessment_results');

    return {
      for (final map in maps)
        map['exercise_id'] as String: map['reps'] as int,
    };
  }

  Future<void> saveAssessment(Map<String, int> results) async {
    final db = await database;
    final batch = db.batch();

    batch.delete('assessment_results');

    for (final entry in results.entries) {
      batch.insert(
        'assessment_results',
        {
          'exercise_id': entry.key,
          'reps': entry.value,
        },
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> clearAll() async {
    final db = await database;
    final batch = db.batch();

    batch.delete('user_profile');
    batch.delete('exercise_levels');
    batch.delete('workout_exercises');
    batch.delete('daily_workouts');
    batch.delete('streak_state');
    batch.delete('assessment_results');

    await batch.commit(noResult: true);
  }
}
