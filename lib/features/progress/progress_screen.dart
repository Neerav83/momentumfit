import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:momentumfit/l10n/app_localizations.dart';
import 'package:momentumfit/l10n/l10n_extras.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_states.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/exercise_level.dart';
import '../../domain/models/workout.dart';
import '../../domain/services/achievements.dart';
import '../../providers/app_providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final levels = ref.watch(levelsProvider);
    final streak = ref.watch(streakProvider);
    final history = ref.watch(workoutHistoryProvider);
    final completed = history.where((w) => w.isCompleted).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final achievements = AchievementService.evaluate(
      streak: streak,
      history: history,
    );

    final tracked = levels.values.toList()
      ..sort((a, b) => b.personalBest.compareTo(a.personalBest));

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            SectionHeader(
              title: l10n.progress,
              subtitle: l10n.progressSubtitle,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _StatBlock(
                    label: l10n.streak,
                    value: '${streak.currentStreak}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatBlock(
                    label: l10n.best,
                    value: '${streak.longestStreak}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatBlock(
                    label: l10n.workouts,
                    value: '${completed.length}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(l10n.recentWorkouts, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            if (completed.isEmpty)
              EmptyState(message: l10n.completeWorkoutToSeeHistory)
            else
              for (final workout in completed.take(10))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _HistoryRow(workout: workout),
                ),
            const SizedBox(height: 24),
            Text(l10n.achievements, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final achievement in achievements)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AchievementRow(achievement: achievement),
              ),
            const SizedBox(height: 24),
            Text(l10n.exerciseTargets, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            if (tracked.isEmpty)
              EmptyState(message: l10n.completeAssessmentToStart)
            else
              for (final level in tracked.take(8))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _LevelCard(level: level),
                ),
          ],
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.forestDark,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.muted,
                ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.workout});

  final DailyWorkout workout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dateLabel = DateFormat.MMMd(Localizations.localeOf(context).toString())
        .format(workout.date);
    final logged = workout.exercises.where((e) => e.done).length;

    return AppCard(
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.forest, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateLabel, style: theme.textTheme.titleMedium),
                Text(
                  l10n.exercisesLogged(logged),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementRow extends StatelessWidget {
  const _AchievementRow({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final labels = achievementLabels(achievement.id, l10n);
    final unlocked = achievement.unlocked;

    return AppCard(
      color: unlocked ? Colors.white : AppColors.mist.withValues(alpha: 0.5),
      child: Row(
        children: [
          Icon(
            unlocked ? Icons.emoji_events_outlined : Icons.lock_outline,
            color: unlocked ? AppColors.forest : AppColors.muted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labels.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: unlocked ? AppColors.ink : AppColors.muted,
                  ),
                ),
                Text(
                  labels.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.level});

  final ExerciseLevel level;

  @override
  Widget build(BuildContext context) {
    final def = ExerciseLibrary.byId(level.exerciseId);
    final l10n = AppLocalizations.of(context)!;
    final name = def.nameOf(l10n);
    final points = level.history.length > 8
        ? level.history.sublist(level.history.length - 8)
        : level.history;
    final maxVal = points.isEmpty
        ? 1
        : points.map((p) => p.completed).reduce((a, b) => a > b ? a : b);
    final safeMax = maxVal == 0 ? 1 : maxVal;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                l10n.targetValue(def.unit.format(level.currentTarget)),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.forest,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.prValue(def.unit.format(level.personalBest)),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                ),
          ),
          const SizedBox(height: 14),
          Semantics(
            label: l10n.recentPerformanceChart(name),
            child: SizedBox(
              height: 56,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final point in points) ...[
                    Expanded(
                      child: Tooltip(
                        message: def.unit.format(point.completed),
                        child: Semantics(
                          label: def.unit.format(point.completed),
                          child: FractionallySizedBox(
                            heightFactor:
                                (point.completed / safeMax).clamp(0.08, 1),
                            alignment: Alignment.bottomCenter,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.forest.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (point != points.last) const SizedBox(width: 4),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
