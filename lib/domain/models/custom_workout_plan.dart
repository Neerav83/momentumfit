import 'dart:convert';

class CustomWorkoutPlan {
  CustomWorkoutPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.weeklySchedule,
    required this.createdAt,
    required this.conversationId,
    this.isActive = false,
  });

  factory CustomWorkoutPlan.fromMap(Map<String, dynamic> map) {
    return CustomWorkoutPlan(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      weeklySchedule: _decodeSchedule(map['weekly_schedule'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      conversationId: map['conversation_id'] as String?,
      isActive: (map['is_active'] as int?) == 1,
    );
  }

  factory CustomWorkoutPlan.fromJson(Map<String, dynamic> json) {
    return CustomWorkoutPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      weeklySchedule: (json['weeklySchedule'] as List<dynamic>)
          .map((e) => DayWorkout.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      conversationId: json['conversationId'] as String?,
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  final String id;
  final String name;
  final String? description;
  final List<DayWorkout> weeklySchedule;
  final DateTime createdAt;
  final String? conversationId;
  final bool isActive;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'weekly_schedule': jsonEncode(
        weeklySchedule.map((d) => d.toJson()).toList(),
      ),
      'created_at': createdAt.toIso8601String(),
      'conversation_id': conversationId,
      'is_active': isActive ? 1 : 0,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'weeklySchedule': weeklySchedule.map((d) => d.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'conversationId': conversationId,
      'isActive': isActive,
    };
  }

  CustomWorkoutPlan copyWith({
    String? id,
    String? name,
    String? description,
    List<DayWorkout>? weeklySchedule,
    DateTime? createdAt,
    String? conversationId,
    bool? isActive,
  }) {
    return CustomWorkoutPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
      createdAt: createdAt ?? this.createdAt,
      conversationId: conversationId ?? this.conversationId,
      isActive: isActive ?? this.isActive,
    );
  }

  static List<DayWorkout> _decodeSchedule(String json) {
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => DayWorkout.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}

class DayWorkout {
  DayWorkout({
    required this.dayOfWeek,
    required this.exercises,
    this.isRestDay = false,
    this.notes,
  });

  factory DayWorkout.fromJson(Map<String, dynamic> json) {
    return DayWorkout(
      dayOfWeek: json['dayOfWeek'] as int,
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => PlannedExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isRestDay: json['isRestDay'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  final int dayOfWeek;
  final List<PlannedExercise> exercises;
  final bool isRestDay;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'isRestDay': isRestDay,
      'notes': notes,
    };
  }
}

class PlannedExercise {
  PlannedExercise({
    required this.exerciseId,
    required this.targetReps,
    this.sets = 1,
    this.restSeconds,
    this.notes,
  });

  factory PlannedExercise.fromJson(Map<String, dynamic> json) {
    return PlannedExercise(
      exerciseId: json['exerciseId'] as String,
      targetReps: json['targetReps'] as int,
      sets: json['sets'] as int? ?? 1,
      restSeconds: json['restSeconds'] as int?,
      notes: json['notes'] as String?,
    );
  }

  final String exerciseId;
  final int targetReps;
  final int sets;
  final int? restSeconds;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'targetReps': targetReps,
      'sets': sets,
      'restSeconds': restSeconds,
      'notes': notes,
    };
  }
}
