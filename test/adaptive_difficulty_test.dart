import 'package:flutter_test/flutter_test.dart';
import 'package:momentumfit/domain/models/enums.dart';
import 'package:momentumfit/domain/models/exercise_level.dart';
import 'package:momentumfit/domain/services/adaptive_difficulty.dart';

void main() {
  group('AdaptiveDifficulty', () {
    test('increases after consecutive full completions', () {
      var level = const ExerciseLevel(
        exerciseId: 'push_ups',
        currentTarget: 6,
        successStreak: 0,
        failStreak: 0,
      );

      level = AdaptiveDifficulty.adapt(
        level: level,
        completed: 6,
        unit: ExerciseUnit.reps,
      );
      expect(level.currentTarget, 6);
      expect(level.successStreak, 1);

      level = AdaptiveDifficulty.adapt(
        level: level,
        completed: 6,
        unit: ExerciseUnit.reps,
      );
      expect(level.currentTarget, 7);
      expect(level.successStreak, 0);
    });

    test('stays same when completion is 80-99%', () {
      var level = const ExerciseLevel(
        exerciseId: 'push_ups',
        currentTarget: 10,
        successStreak: 1,
        failStreak: 0,
      );

      level = AdaptiveDifficulty.adapt(
        level: level,
        completed: 9,
        unit: ExerciseUnit.reps,
      );
      expect(level.currentTarget, 10);
      expect(level.successStreak, 0);
      expect(level.failStreak, 0);
    });

    test('decreases after repeated failures', () {
      var level = const ExerciseLevel(
        exerciseId: 'push_ups',
        currentTarget: 10,
        successStreak: 0,
        failStreak: 0,
      );

      level = AdaptiveDifficulty.adapt(
        level: level,
        completed: 5,
        unit: ExerciseUnit.reps,
      );
      expect(level.failStreak, 1);

      level = AdaptiveDifficulty.adapt(
        level: level,
        completed: 5,
        unit: ExerciseUnit.reps,
      );
      expect(level.currentTarget, 8);
    });
  });
}
