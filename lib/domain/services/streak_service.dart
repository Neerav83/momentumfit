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
        // Missed day(s) — streak resets (freeze handled separately later).
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
      return current.copyWith(freezeCount: freezes);
    }

    return current.copyWith(
      currentStreak: 0,
      freezeCount: 0,
    );
  }
}
