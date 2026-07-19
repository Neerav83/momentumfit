import '../models/workout.dart';

class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.unlocked,
  });

  final String id;
  final String title;
  final String description;
  final bool unlocked;
}

/// Simple local achievements derived from streak + history.
abstract final class AchievementService {
  static List<Achievement> evaluate({
    required StreakState streak,
    required List<DailyWorkout> history,
  }) {
    final completed = history.where((w) => w.isCompleted).length;

    return [
      Achievement(
        id: 'first_workout',
        title: 'First step',
        description: 'Complete your first workout',
        unlocked: completed >= 1,
      ),
      Achievement(
        id: 'streak_3',
        title: 'Three in a row',
        description: 'Reach a 3-day streak',
        unlocked: streak.longestStreak >= 3 || streak.currentStreak >= 3,
      ),
      Achievement(
        id: 'streak_7',
        title: 'Week of momentum',
        description: 'Reach a 7-day streak',
        unlocked: streak.longestStreak >= 7 || streak.currentStreak >= 7,
      ),
      Achievement(
        id: 'workouts_10',
        title: 'Ten sessions',
        description: 'Complete 10 workouts',
        unlocked: completed >= 10,
      ),
      Achievement(
        id: 'freeze_earned',
        title: 'Safety net',
        description: 'Earn a streak freeze',
        unlocked: streak.freezeCount > 0 || streak.lastFreezeEarnedAt != null,
      ),
    ];
  }
}
