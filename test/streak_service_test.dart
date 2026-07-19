import 'package:flutter_test/flutter_test.dart';
import 'package:momentumfit/domain/models/workout.dart';
import 'package:momentumfit/domain/services/streak_service.dart';

void main() {
  group('StreakService', () {
    final monday = DateTime(2026, 7, 13);
    final tuesday = DateTime(2026, 7, 14);
    final wednesday = DateTime(2026, 7, 15);
    final thursday = DateTime(2026, 7, 16);

    test('increments streak on consecutive days', () {
      var state = StreakState.empty;
      state = StreakService.onWorkoutCompleted(
        current: state,
        completedAt: monday,
      );
      expect(state.currentStreak, 1);

      state = StreakService.onWorkoutCompleted(
        current: state,
        completedAt: tuesday,
      );
      expect(state.currentStreak, 2);
      expect(state.longestStreak, 2);
    });

    test('resets streak when missing a day without freezes', () {
      var state = StreakState(
        currentStreak: 5,
        longestStreak: 5,
        lastCompletedDate: DateTime(2026, 7, 13),
      );

      state = StreakService.evaluateMissedDays(
        current: state,
        now: wednesday,
      );
      expect(state.currentStreak, 0);
      expect(state.freezeCount, 0);

      state = StreakService.onWorkoutCompleted(
        current: state,
        completedAt: wednesday,
      );
      expect(state.currentStreak, 1);
    });

    test('freeze preserves streak across a missed day', () {
      var state = StreakState(
        currentStreak: 5,
        longestStreak: 5,
        lastCompletedDate: DateTime(2026, 7, 13), // Monday
        freezeCount: 1,
      );

      // Open app on Wednesday — Tuesday was missed, freeze covers it.
      state = StreakService.evaluateMissedDays(
        current: state,
        now: wednesday,
      );
      expect(state.currentStreak, 5);
      expect(state.freezeCount, 0);
      expect(
        StreakService.isSameDay(state.lastCompletedDate!, tuesday),
        isTrue,
      );

      // Complete Wednesday workout — streak continues.
      state = StreakService.onWorkoutCompleted(
        current: state,
        completedAt: wednesday,
      );
      expect(state.currentStreak, 6);
      expect(state.longestStreak, 6);
    });

    test('two freezes cover two missed days', () {
      var state = StreakState(
        currentStreak: 10,
        longestStreak: 10,
        lastCompletedDate: DateTime(2026, 7, 13), // Monday
        freezeCount: 2,
      );

      // Open on Thursday — Tue + Wed missed.
      state = StreakService.evaluateMissedDays(
        current: state,
        now: thursday,
      );
      expect(state.currentStreak, 10);
      expect(state.freezeCount, 0);
      expect(
        StreakService.isSameDay(
          state.lastCompletedDate!,
          thursday.subtract(const Duration(days: 1)),
        ),
        isTrue,
      );

      state = StreakService.onWorkoutCompleted(
        current: state,
        completedAt: thursday,
      );
      expect(state.currentStreak, 11);
    });

    test('earns a freeze every 30 streak days', () {
      var state = StreakState(
        currentStreak: 29,
        longestStreak: 29,
        lastCompletedDate: DateTime(2026, 6, 13),
        freezeCount: 0,
      );

      state = StreakService.onWorkoutCompleted(
        current: state,
        completedAt: DateTime(2026, 6, 14),
      );
      expect(state.currentStreak, 30);
      expect(state.freezeCount, 1);
      expect(state.lastFreezeEarnedAt, isNotNull);
    });

    test('does not exceed max of 2 freezes', () {
      var state = StreakState(
        currentStreak: 29,
        longestStreak: 29,
        lastCompletedDate: DateTime(2026, 6, 13),
        freezeCount: 2,
      );

      state = StreakService.onWorkoutCompleted(
        current: state,
        completedAt: DateTime(2026, 6, 14),
      );
      expect(state.currentStreak, 30);
      expect(state.freezeCount, 2);
    });

    test('same-day completion is idempotent', () {
      var state = StreakService.onWorkoutCompleted(
        current: StreakState.empty,
        completedAt: monday,
      );
      final again = StreakService.onWorkoutCompleted(
        current: state,
        completedAt: monday.add(const Duration(hours: 3)),
      );
      expect(again.currentStreak, 1);
      expect(again.freezeCount, state.freezeCount);
    });
  });
}
