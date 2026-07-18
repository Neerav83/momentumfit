import 'package:flutter_test/flutter_test.dart';
import 'package:momentumfit/domain/models/avatar.dart';
import 'package:momentumfit/domain/models/enums.dart';
import 'package:momentumfit/domain/models/exercise_level.dart';
import 'package:momentumfit/domain/models/user_profile.dart';
import 'package:momentumfit/domain/models/workout.dart';
import 'package:momentumfit/domain/services/coach_insights.dart';
import 'package:momentumfit/domain/services/coach_templates.dart';

void main() {
  final profile = UserProfile(
    name: 'Alex',
    avatarId: AvatarOption.fox.id,
    age: 28,
    heightCm: 175,
    weightKg: 75,
    activityLevel: ActivityLevel.beginner,
    injuries: {Injury.none},
    onboardingCompleted: true,
    assessmentCompleted: true,
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
  );

  test('first completed workout uses firstWorkout scenario', () {
    final today = DateTime.now();
    final workout = DailyWorkout(
      id: '1',
      date: today,
      completedAt: today,
      exercises: const [
        WorkoutExercise(
          exerciseId: 'push_ups',
          target: 5,
          completed: 5,
          done: true,
        ),
      ],
    );

    final insights = CoachInsightBuilder.build(
      profile: profile,
      streak: const StreakState(currentStreak: 1, longestStreak: 1),
      workout: workout,
      history: [workout],
      levels: {
        'push_ups': ExerciseLevel(
          exerciseId: 'push_ups',
          currentTarget: 5,
          successStreak: 0,
          failStreak: 0,
          personalBest: 5,
          history: [
            LevelHistoryPoint(date: DateTime(2026, 1, 1), target: 5, completed: 5),
          ],
        ),
      },
    );

    expect(insights.scenario, CoachScenario.firstWorkout);
    final text = CoachTemplates.fromInsights(insights);
    expect(text.toLowerCase(), contains('first workout'));
  });

  test('seven day streak uses weekStreak scenario', () {
    final today = DateTime.now();
    final workout = DailyWorkout(
      id: '7',
      date: today,
      completedAt: today,
      exercises: const [
        WorkoutExercise(
          exerciseId: 'squats',
          target: 10,
          completed: 9,
          done: true,
        ),
      ],
    );

    final history = <DailyWorkout>[
      for (var i = 6; i >= 0; i--)
        DailyWorkout(
          id: '$i',
          date: today.subtract(Duration(days: i)),
          completedAt: today.subtract(Duration(days: i)),
          exercises: const [
            WorkoutExercise(
              exerciseId: 'squats',
              target: 10,
              completed: 10,
              done: true,
            ),
          ],
        ),
    ];

    final insights = CoachInsightBuilder.build(
      profile: profile,
      streak: const StreakState(currentStreak: 7, longestStreak: 7),
      workout: workout,
      history: history,
      levels: const {},
    );

    expect(insights.scenario, CoachScenario.weekStreak);
    expect(CoachTemplates.fromInsights(insights), contains('Seven days'));
  });

  test('improvement fact appears in prompt facts', () {
    final insights = CoachInsightBuilder.build(
      profile: profile,
      streak: const StreakState(currentStreak: 3, longestStreak: 3),
      workout: DailyWorkout(
        id: 'x',
        date: DateTime.now(),
        exercises: const [
          WorkoutExercise(exerciseId: 'push_ups', target: 8),
        ],
      ),
      history: const [],
      levels: {
        'push_ups': ExerciseLevel(
          exerciseId: 'push_ups',
          currentTarget: 8,
          successStreak: 0,
          failStreak: 0,
          personalBest: 10,
          history: [
            LevelHistoryPoint(
              date: DateTime.now().subtract(const Duration(days: 30)),
              target: 6,
              completed: 6,
            ),
            LevelHistoryPoint(
              date: DateTime.now(),
              target: 8,
              completed: 10,
            ),
          ],
        ),
      },
    );

    expect(insights.improvements, isNotEmpty);
    expect(insights.improvements.first.percentGain, 67);
  });
}
