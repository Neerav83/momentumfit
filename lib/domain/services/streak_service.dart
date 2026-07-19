import '../models/workout.dart';

abstract final class StreakService {
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static int daysBetween(DateTime a, DateTime b) {
    final aa = dateOnly(a);
    final bb = dateOnly(b);
    return bb.difference(aa).inDays;
  }

  /// Apply streak rules when a workout is completed today.
  ///
  /// Call [evaluateMissedDays] first so freezes have already advanced
  /// [StreakState.lastCompletedDate] when protecting missed days.
  static StreakState onWorkoutCompleted({
    required StreakState current,
    required DateTime completedAt,
  }) {
    final today = dateOnly(completedAt);
    final last = current.lastCompletedDate;

    if (last != null && isSameDay(last, today)) {
      return current;
    }

    var streak = 1;
    if (last != null) {
      final gap = daysBetween(last, today);
      if (gap == 1) {
        streak = current.currentStreak + 1;
      } else if (gap > 1) {
        // Missed day(s) without freeze coverage — streak resets.
        streak = 1;
      }
    }

    final longest =
        streak > current.longestStreak ? streak : current.longestStreak;

    var freezes = current.freezeCount;
    var lastFreezeEarned = current.lastFreezeEarnedAt;

    // Earn one freeze every 30 streak days, max 2.
    if (streak > 0 && streak % 30 == 0 && freezes < 2) {
      freezes += 1;
      lastFreezeEarned = today;
    }

    return current.copyWith(
      currentStreak: streak,
      longestStreak: longest,
      lastCompletedDate: today,
      freezeCount: freezes,
      lastFreezeEarnedAt: lastFreezeEarned,
    );
  }

  /// Evaluate whether the streak should break due to a missed day.
  ///
  /// When freezes cover the miss, consume them and advance
  /// [StreakState.lastCompletedDate] to yesterday so the next completion
  /// continues the streak (gap == 1).
  static StreakState evaluateMissedDays({
    required StreakState current,
    required DateTime now,
  }) {
    final last = current.lastCompletedDate;
    if (last == null || current.currentStreak == 0) return current;

    final today = dateOnly(now);
    final gap = daysBetween(last, today);

    if (gap <= 1) return current;

    // gap == 2 means one full day was skipped.
    final missedDays = gap - 1;
    var freezes = current.freezeCount;

    if (missedDays <= freezes) {
      freezes -= missedDays;
      // Treat freeze-protected days as completed so the next workout
      // continues the streak instead of resetting.
      final protectedThrough = today.subtract(const Duration(days: 1));
      return current.copyWith(
        freezeCount: freezes,
        lastCompletedDate: protectedThrough,
      );
    }

    return current.copyWith(
      currentStreak: 0,
      freezeCount: 0,
    );
  }
}
