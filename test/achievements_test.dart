import 'package:flutter_test/flutter_test.dart';
import 'package:momentumfit/domain/models/workout.dart';
import 'package:momentumfit/domain/services/achievements.dart';

void main() {
  group('AchievementService', () {
    test('unlocks first workout and streak achievements', () {
      final history = [
        DailyWorkout(
          id: '1',
          date: DateTime(2026, 7, 1),
          exercises: const [],
          completedAt: DateTime(2026, 7, 1),
        ),
      ];
      final streak = const StreakState(
        currentStreak: 7,
        longestStreak: 7,
      );

      final result = AchievementService.evaluate(
        streak: streak,
        history: history,
      );

      expect(
        result.firstWhere((a) => a.id == 'first_workout').unlocked,
        isTrue,
      );
      expect(result.firstWhere((a) => a.id == 'streak_7').unlocked, isTrue);
      expect(
        result.firstWhere((a) => a.id == 'workouts_10').unlocked,
        isFalse,
      );
    });
  });
}
