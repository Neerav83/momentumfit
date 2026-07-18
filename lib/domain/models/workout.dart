class StreakState {
  const StreakState({
    required this.currentStreak,
    required this.longestStreak,
    this.lastCompletedDate,
    this.freezeCount = 0,
    this.lastFreezeEarnedAt,
  });

  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedDate;
  final int freezeCount;
  final DateTime? lastFreezeEarnedAt;

  StreakState copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCompletedDate,
    int? freezeCount,
    DateTime? lastFreezeEarnedAt,
  }) {
    return StreakState(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      freezeCount: freezeCount ?? this.freezeCount,
      lastFreezeEarnedAt: lastFreezeEarnedAt ?? this.lastFreezeEarnedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastCompletedDate': lastCompletedDate?.toIso8601String(),
        'freezeCount': freezeCount,
        'lastFreezeEarnedAt': lastFreezeEarnedAt?.toIso8601String(),
      };

  factory StreakState.fromJson(Map<String, dynamic> json) {
    return StreakState(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastCompletedDate: json['lastCompletedDate'] != null
          ? DateTime.tryParse(json['lastCompletedDate'] as String)
          : null,
      freezeCount: json['freezeCount'] as int? ?? 0,
      lastFreezeEarnedAt: json['lastFreezeEarnedAt'] != null
          ? DateTime.tryParse(json['lastFreezeEarnedAt'] as String)
          : null,
    );
  }

  static const empty = StreakState(currentStreak: 0, longestStreak: 0);
}

class WorkoutExercise {
  const WorkoutExercise({
    required this.exerciseId,
    required this.target,
    this.completed,
    this.done = false,
  });

  final String exerciseId;
  final int target;
  final int? completed;
  final bool done;

  double get completionRatio {
    if (completed == null || target <= 0) return 0;
    return (completed! / target).clamp(0.0, 1.5);
  }

  WorkoutExercise copyWith({
    String? exerciseId,
    int? target,
    int? completed,
    bool? done,
  }) {
    return WorkoutExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      target: target ?? this.target,
      completed: completed ?? this.completed,
      done: done ?? this.done,
    );
  }

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'target': target,
        'completed': completed,
        'done': done,
      };

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      exerciseId: json['exerciseId'] as String,
      target: json['target'] as int,
      completed: json['completed'] as int?,
      done: json['done'] as bool? ?? false,
    );
  }
}

class DailyWorkout {
  const DailyWorkout({
    required this.id,
    required this.date,
    required this.exercises,
    this.completedAt,
  });

  final String id;
  final DateTime date;
  final List<WorkoutExercise> exercises;
  final DateTime? completedAt;

  bool get isCompleted => completedAt != null;

  bool get allMarked =>
      exercises.isNotEmpty && exercises.every((e) => e.done);

  DailyWorkout copyWith({
    String? id,
    DateTime? date,
    List<WorkoutExercise>? exercises,
    DateTime? completedAt,
  }) {
    return DailyWorkout(
      id: id ?? this.id,
      date: date ?? this.date,
      exercises: exercises ?? this.exercises,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'completedAt': completedAt?.toIso8601String(),
      };

  factory DailyWorkout.fromJson(Map<String, dynamic> json) {
    return DailyWorkout(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      exercises: [
        for (final e in (json['exercises'] as List<dynamic>? ?? const []))
          WorkoutExercise.fromJson(e as Map<String, dynamic>),
      ],
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
    );
  }
}
