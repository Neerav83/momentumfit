class ExerciseLevel {
  const ExerciseLevel({
    required this.exerciseId,
    required this.currentTarget,
    required this.successStreak,
    required this.failStreak,
    this.personalBest = 0,
    this.history = const [],
  });

  final String exerciseId;
  final int currentTarget;
  final int successStreak;
  final int failStreak;
  final int personalBest;
  final List<LevelHistoryPoint> history;

  ExerciseLevel copyWith({
    String? exerciseId,
    int? currentTarget,
    int? successStreak,
    int? failStreak,
    int? personalBest,
    List<LevelHistoryPoint>? history,
  }) {
    return ExerciseLevel(
      exerciseId: exerciseId ?? this.exerciseId,
      currentTarget: currentTarget ?? this.currentTarget,
      successStreak: successStreak ?? this.successStreak,
      failStreak: failStreak ?? this.failStreak,
      personalBest: personalBest ?? this.personalBest,
      history: history ?? this.history,
    );
  }

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'currentTarget': currentTarget,
        'successStreak': successStreak,
        'failStreak': failStreak,
        'personalBest': personalBest,
        'history': history.map((e) => e.toJson()).toList(),
      };

  factory ExerciseLevel.fromJson(Map<String, dynamic> json) {
    return ExerciseLevel(
      exerciseId: json['exerciseId'] as String,
      currentTarget: json['currentTarget'] as int,
      successStreak: json['successStreak'] as int? ?? 0,
      failStreak: json['failStreak'] as int? ?? 0,
      personalBest: json['personalBest'] as int? ?? 0,
      history: [
        for (final h in (json['history'] as List<dynamic>? ?? const []))
          LevelHistoryPoint.fromJson(h as Map<String, dynamic>),
      ],
    );
  }
}

class LevelHistoryPoint {
  const LevelHistoryPoint({
    required this.date,
    required this.target,
    required this.completed,
  });

  final DateTime date;
  final int target;
  final int completed;

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'target': target,
        'completed': completed,
      };

  factory LevelHistoryPoint.fromJson(Map<String, dynamic> json) {
    return LevelHistoryPoint(
      date: DateTime.parse(json['date'] as String),
      target: json['target'] as int,
      completed: json['completed'] as int,
    );
  }
}
