enum ActivityLevel {
  beginner,
  sometimes,
  regular;

  String get label => switch (this) {
        ActivityLevel.beginner => 'Beginner',
        ActivityLevel.sometimes => 'Sometimes active',
        ActivityLevel.regular => 'Regularly active',
      };

  String get description => switch (this) {
        ActivityLevel.beginner => 'Just getting started',
        ActivityLevel.sometimes => 'A few times a month',
        ActivityLevel.regular => 'Several times a week',
      };

  /// Starting difficulty multiplier relative to assessment results.
  double get startMultiplier => switch (this) {
        ActivityLevel.beginner => 0.35,
        ActivityLevel.sometimes => 0.45,
        ActivityLevel.regular => 0.55,
      };

  static ActivityLevel fromName(String name) =>
      ActivityLevel.values.firstWhere(
        (e) => e.name == name,
        orElse: () => ActivityLevel.beginner,
      );
}

enum Injury {
  knees,
  back,
  shoulders,
  none;

  String get label => switch (this) {
        Injury.knees => 'Knees',
        Injury.back => 'Back',
        Injury.shoulders => 'Shoulders',
        Injury.none => 'None',
      };

  static Injury fromName(String name) => Injury.values.firstWhere(
        (e) => e.name == name,
        orElse: () => Injury.none,
      );
}

enum ExerciseCategory {
  upperBody,
  legs,
  core,
  cardio;

  String get label => switch (this) {
        ExerciseCategory.upperBody => 'Upper body',
        ExerciseCategory.legs => 'Legs',
        ExerciseCategory.core => 'Core',
        ExerciseCategory.cardio => 'Cardio',
      };
}

enum ExerciseUnit {
  reps,
  seconds;

  String format(int value) => switch (this) {
        ExerciseUnit.reps => '$value',
        ExerciseUnit.seconds => '${value}s',
      };
}
