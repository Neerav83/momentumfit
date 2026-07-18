import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/exercise_level.dart';
import '../../providers/app_providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final levels = ref.watch(levelsProvider);
    final streak = ref.watch(streakProvider);
    final history = ref.watch(workoutHistoryProvider);
    final completedDays =
        history.where((w) => w.isCompleted).length;

    final tracked = levels.values.toList()
      ..sort((a, b) => b.personalBest.compareTo(a.personalBest));

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            Text('Progress', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(
              'Small gains, clearly visible.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _StatBlock(
                    label: 'Current streak',
                    value: '${streak.currentStreak}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatBlock(
                    label: 'Best streak',
                    value: '${streak.longestStreak}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatBlock(
                    label: 'Workouts',
                    value: '$completedDays',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('Exercise levels', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            if (tracked.isEmpty)
              Text(
                'Complete your assessment to start tracking.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                ),
              )
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
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

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.level});

  final ExerciseLevel level;

  @override
  Widget build(BuildContext context) {
    final def = ExerciseLibrary.byId(level.exerciseId);
    final points = level.history.length > 8
        ? level.history.sublist(level.history.length - 8)
        : level.history;
    final maxVal = points.isEmpty
        ? 1
        : points.map((p) => p.completed).reduce((a, b) => a > b ? a : b);
    final safeMax = maxVal == 0 ? 1 : maxVal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  def.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                'Level ${def.unit.format(level.currentTarget)}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.forest,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'PR ${def.unit.format(level.personalBest)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 56,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final point in points) ...[
                  Expanded(
                    child: Tooltip(
                      message: def.unit.format(point.completed),
                      child: FractionallySizedBox(
                        heightFactor: (point.completed / safeMax).clamp(0.08, 1),
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
                  if (point != points.last) const SizedBox(width: 4),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
