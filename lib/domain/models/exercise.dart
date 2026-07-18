import 'enums.dart';

class ExerciseDefinition {
  const ExerciseDefinition({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.cue,
    this.contraindications = const {},
    this.assessmentExercise = false,
  });

  final String id;
  final String name;
  final ExerciseCategory category;
  final ExerciseUnit unit;
  final String cue;
  final Set<Injury> contraindications;
  final bool assessmentExercise;
}

/// Seed catalog for MVP. Assessment exercises drive initial levels.
abstract final class ExerciseLibrary {
  static const pushUps = ExerciseDefinition(
    id: 'push_ups',
    name: 'Push-ups',
    category: ExerciseCategory.upperBody,
    unit: ExerciseUnit.reps,
    cue: 'Do as many as you can with good form.',
    contraindications: {Injury.shoulders},
    assessmentExercise: true,
  );

  static const kneePushUps = ExerciseDefinition(
    id: 'knee_push_ups',
    name: 'Knee push-ups',
    category: ExerciseCategory.upperBody,
    unit: ExerciseUnit.reps,
    cue: 'Keep your core tight and lower with control.',
  );

  static const chairDips = ExerciseDefinition(
    id: 'chair_dips',
    name: 'Chair dips',
    category: ExerciseCategory.upperBody,
    unit: ExerciseUnit.reps,
    cue: 'Lower until elbows are around 90 degrees.',
    contraindications: {Injury.shoulders},
  );

  static const squats = ExerciseDefinition(
    id: 'squats',
    name: 'Squats',
    category: ExerciseCategory.legs,
    unit: ExerciseUnit.reps,
    cue: 'Do as many as you can.',
    contraindications: {Injury.knees},
    assessmentExercise: true,
  );

  static const lunges = ExerciseDefinition(
    id: 'lunges',
    name: 'Lunges',
    category: ExerciseCategory.legs,
    unit: ExerciseUnit.reps,
    cue: 'Alternate legs. Count total reps.',
    contraindications: {Injury.knees},
  );

  static const gluteBridge = ExerciseDefinition(
    id: 'glute_bridge',
    name: 'Glute bridge',
    category: ExerciseCategory.legs,
    unit: ExerciseUnit.reps,
    cue: 'Squeeze at the top, then lower slowly.',
    contraindications: {Injury.back},
  );

  static const calfRaises = ExerciseDefinition(
    id: 'calf_raises',
    name: 'Calf raises',
    category: ExerciseCategory.legs,
    unit: ExerciseUnit.reps,
    cue: 'Rise onto your toes, pause, then lower.',
  );

  static const plank = ExerciseDefinition(
    id: 'plank',
    name: 'Plank',
    category: ExerciseCategory.core,
    unit: ExerciseUnit.seconds,
    cue: 'Hold as long as possible.',
    assessmentExercise: true,
  );

  static const sidePlank = ExerciseDefinition(
    id: 'side_plank',
    name: 'Side plank',
    category: ExerciseCategory.core,
    unit: ExerciseUnit.seconds,
    cue: 'Hold each side. Log the weaker side.',
    contraindications: {Injury.shoulders},
  );

  static const deadBug = ExerciseDefinition(
    id: 'dead_bug',
    name: 'Dead bug',
    category: ExerciseCategory.core,
    unit: ExerciseUnit.reps,
    cue: 'Move slowly and keep your lower back pressed down.',
    contraindications: {Injury.back},
  );

  static const birdDog = ExerciseDefinition(
    id: 'bird_dog',
    name: 'Bird dog',
    category: ExerciseCategory.core,
    unit: ExerciseUnit.reps,
    cue: 'Extend opposite arm and leg, then switch.',
    contraindications: {Injury.back},
  );

  static const jumpingJacks = ExerciseDefinition(
    id: 'jumping_jacks',
    name: 'Jumping jacks',
    category: ExerciseCategory.cardio,
    unit: ExerciseUnit.reps,
    cue: 'Keep a steady rhythm.',
    contraindications: {Injury.knees},
  );

  static const highKnees = ExerciseDefinition(
    id: 'high_knees',
    name: 'High knees',
    category: ExerciseCategory.cardio,
    unit: ExerciseUnit.reps,
    cue: 'Drive knees up and stay light on your feet.',
    contraindications: {Injury.knees},
  );

  static const mountainClimbers = ExerciseDefinition(
    id: 'mountain_climbers',
    name: 'Mountain climbers',
    category: ExerciseCategory.cardio,
    unit: ExerciseUnit.reps,
    cue: 'Keep hips level as you alternate legs.',
    contraindications: {Injury.shoulders, Injury.back},
  );

  static const all = <ExerciseDefinition>[
    pushUps,
    kneePushUps,
    chairDips,
    squats,
    lunges,
    gluteBridge,
    calfRaises,
    plank,
    sidePlank,
    deadBug,
    birdDog,
    jumpingJacks,
    highKnees,
    mountainClimbers,
  ];

  static ExerciseDefinition byId(String id) {
    return all.firstWhere(
      (e) => e.id == id,
      orElse: () => pushUps,
    );
  }

  static List<ExerciseDefinition> get assessmentExercises =>
      all.where((e) => e.assessmentExercise).toList();

  static List<ExerciseDefinition> availableFor(Set<Injury> injuries) {
    final blocked = injuries.where((i) => i != Injury.none).toSet();
    if (blocked.isEmpty) return List.of(all);
    return all
        .where((e) => e.contraindications.intersection(blocked).isEmpty)
        .toList();
  }
}
