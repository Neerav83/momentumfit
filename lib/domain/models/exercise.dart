import 'enums.dart';

class ExerciseDefinition {
  const ExerciseDefinition({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.cue,
    required this.howTo,
    this.contraindications = const {},
    this.assessmentExercise = false,
  });

  final String id;
  final String name;
  final ExerciseCategory category;
  final ExerciseUnit unit;

  /// Short tip shown in lists.
  final String cue;

  /// Clear step-by-step explanation.
  final String howTo;
  final Set<Injury> contraindications;
  final bool assessmentExercise;
}

/// Seed exercises catalog. Assessment exercises drive initial levels.
abstract final class ExerciseLibrary {
  static const pushUps = ExerciseDefinition(
    id: 'push_ups',
    name: 'Push-ups',
    category: ExerciseCategory.upperBody,
    unit: ExerciseUnit.reps,
    cue: 'Chest to the floor with control.',
    howTo:
        'Start in a high plank with hands under your shoulders. Lower your chest toward the floor, keeping elbows close to your body, then press back up. Keep your body in a straight line from head to heels.',
    contraindications: {Injury.shoulders},
    assessmentExercise: true,
  );

  static const kneePushUps = ExerciseDefinition(
    id: 'knee_push_ups',
    name: 'Knee push-ups',
    category: ExerciseCategory.upperBody,
    unit: ExerciseUnit.reps,
    cue: 'Same as push-ups, from the knees.',
    howTo:
        'Kneel on the floor and place your hands under your shoulders. Keep a straight line from knees to head. Lower your chest toward the floor, then press back up with control.',
  );

  static const chairDips = ExerciseDefinition(
    id: 'chair_dips',
    name: 'Chair dips',
    category: ExerciseCategory.upperBody,
    unit: ExerciseUnit.reps,
    cue: 'Lower until elbows are near 90°.',
    howTo:
        'Sit on the edge of a sturdy chair, hands beside your hips. Slide forward so your hips clear the seat. Bend your elbows to lower your body, then press up. Keep shoulders down and away from your ears.',
    contraindications: {Injury.shoulders},
  );

  static const squats = ExerciseDefinition(
    id: 'squats',
    name: 'Squats',
    category: ExerciseCategory.legs,
    unit: ExerciseUnit.reps,
    cue: 'Sit back, chest up, heels down.',
    howTo:
        'Stand with feet about shoulder-width apart. Sit your hips back as if into a chair, keep your chest lifted, and lower until thighs are roughly parallel to the floor (or as deep as comfortable). Drive through your heels to stand.',
    contraindications: {Injury.knees},
    assessmentExercise: true,
  );

  static const lunges = ExerciseDefinition(
    id: 'lunges',
    name: 'Lunges',
    category: ExerciseCategory.legs,
    unit: ExerciseUnit.reps,
    cue: 'Alternate legs. Count every step.',
    howTo:
        'Step one foot forward and bend both knees until the back knee nearly touches the floor. Keep your front knee above your ankle. Push back to standing and switch legs. Count total reps across both sides.',
    contraindications: {Injury.knees},
  );

  static const gluteBridge = ExerciseDefinition(
    id: 'glute_bridge',
    name: 'Glute bridge',
    category: ExerciseCategory.legs,
    unit: ExerciseUnit.reps,
    cue: 'Squeeze at the top, then lower.',
    howTo:
        'Lie on your back with knees bent and feet flat on the floor. Press through your heels to lift your hips until your body forms a straight line from shoulders to knees. Squeeze your glutes at the top, then lower slowly.',
    contraindications: {Injury.back},
  );

  static const calfRaises = ExerciseDefinition(
    id: 'calf_raises',
    name: 'Calf raises',
    category: ExerciseCategory.legs,
    unit: ExerciseUnit.reps,
    cue: 'Rise onto your toes, pause, lower.',
    howTo:
        'Stand tall with feet hip-width apart. Rise onto the balls of your feet as high as you can, pause briefly, then lower with control. Hold a wall or chair for balance if needed.',
  );

  static const plank = ExerciseDefinition(
    id: 'plank',
    name: 'Plank',
    category: ExerciseCategory.core,
    unit: ExerciseUnit.seconds,
    cue: 'Hold a straight line — no sagging.',
    howTo:
        'Place forearms on the floor with elbows under shoulders, or hold a high plank on your hands. Keep your body straight from head to heels. Brace your core, squeeze your glutes, and breathe steadily. Stop if your form breaks.',
    assessmentExercise: true,
  );

  static const sidePlank = ExerciseDefinition(
    id: 'side_plank',
    name: 'Side plank',
    category: ExerciseCategory.core,
    unit: ExerciseUnit.seconds,
    cue: 'Log the weaker side’s time.',
    howTo:
        'Lie on one side with your elbow under your shoulder. Lift your hips so your body forms a straight line. Hold, then switch sides. Log the time of your weaker side.',
    contraindications: {Injury.shoulders},
  );

  static const deadBug = ExerciseDefinition(
    id: 'dead_bug',
    name: 'Dead bug',
    category: ExerciseCategory.core,
    unit: ExerciseUnit.reps,
    cue: 'Slow moves, back pressed down.',
    howTo:
        'Lie on your back with arms toward the ceiling and knees bent at 90°. Slowly extend opposite arm and leg toward the floor without letting your lower back arch. Return and switch sides. One rep = both sides once.',
    contraindications: {Injury.back},
  );

  static const birdDog = ExerciseDefinition(
    id: 'bird_dog',
    name: 'Bird dog',
    category: ExerciseCategory.core,
    unit: ExerciseUnit.reps,
    cue: 'Opposite arm and leg, then switch.',
    howTo:
        'Start on all fours with hands under shoulders and knees under hips. Extend one arm forward and the opposite leg back, keeping hips level. Pause, return, then switch. One rep = both sides once.',
    contraindications: {Injury.back},
  );

  static const jumpingJacks = ExerciseDefinition(
    id: 'jumping_jacks',
    name: 'Jumping jacks',
    category: ExerciseCategory.cardio,
    unit: ExerciseUnit.reps,
    cue: 'Steady rhythm, soft landings.',
    howTo:
        'Stand with feet together and arms at your sides. Jump your feet out while raising your arms overhead, then jump back to the start. Land softly and keep a steady pace.',
    contraindications: {Injury.knees},
  );

  static const highKnees = ExerciseDefinition(
    id: 'high_knees',
    name: 'High knees',
    category: ExerciseCategory.cardio,
    unit: ExerciseUnit.reps,
    cue: 'Drive knees up, stay light.',
    howTo:
        'Jog in place while driving your knees up toward hip height. Pump your arms and stay on the balls of your feet. Count each knee drive as one rep.',
    contraindications: {Injury.knees},
  );

  static const mountainClimbers = ExerciseDefinition(
    id: 'mountain_climbers',
    name: 'Mountain climbers',
    category: ExerciseCategory.cardio,
    unit: ExerciseUnit.reps,
    cue: 'Hips level as you switch legs.',
    howTo:
        'Start in a high plank. Drive one knee toward your chest, then quickly switch legs as if running in place. Keep hips low and level. Count each knee drive as one rep.',
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

  static ExerciseDefinition? tryById(String id) {
    for (final e in all) {
      if (e.id == id) return e;
    }
    return null;
  }

  static ExerciseDefinition byId(String id) {
    return tryById(id) ??
        ExerciseDefinition(
          id: id,
          name: 'Unknown exercise',
          category: ExerciseCategory.upperBody,
          unit: ExerciseUnit.reps,
          cue: 'This exercise is no longer in the catalog.',
          howTo: 'Skip or re-take your assessment to refresh your plan.',
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
