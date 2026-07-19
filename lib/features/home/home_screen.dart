import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_states.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/workout.dart';
import '../../domain/services/input_limits.dart';
import '../../providers/app_providers.dart';
import '../../providers/coach_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(profileProvider);
    final streak = ref.watch(streakProvider);
    final workoutAsync = ref.watch(todaysWorkoutProvider);

    if (profile == null) {
      return const LoadingScaffold();
    }

    return Scaffold(
      body: SafeArea(
        child: workoutAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => ErrorState(
            onRetry: () => ref.invalidate(todaysWorkoutProvider),
          ),
          data: (workout) {
            final done = workout?.isCompleted ?? false;

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              children: [
                Row(
                  children: [
                    Text(
                      profile.avatar.emoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${_greeting()}, ${profile.name}',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _StreakBanner(
                  streak: streak.currentStreak,
                  freezes: streak.freezeCount,
                  workoutDoneToday: done,
                ),
                const SizedBox(height: 28),
                if (done)
                  _DoneForToday(streak: streak.currentStreak)
                else ...[
                  Text(
                    "Today's workout",
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Just a few moves. Keep it easy.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (workout == null)
                    const EmptyState(message: 'No workout yet.')
                  else ...[
                    for (var i = 0; i < workout.exercises.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ExerciseRow(
                          item: workout.exercises[i],
                          enabled: true,
                          onComplete: (completed) {
                            ref
                                .read(todaysWorkoutProvider.notifier)
                                .markExercise(index: i, completed: completed);
                          },
                        ),
                      ),
                    if (!workout.allMarked) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Log every exercise to finish today’s workout.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: workout.allMarked
                          ? () async {
                              await ref
                                  .read(todaysWorkoutProvider.notifier)
                                  .finishWorkout();
                              ref.invalidate(coachNudgeProvider);
                              if (context.mounted) {
                                _showCompletionDialog(context, ref);
                              }
                            }
                          : null,
                      child: const Text('Complete workout'),
                    ),
                  ],
                ],
                const SizedBox(height: 20),
                const _CoachNudgeCard(),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, WidgetRef ref) {
    final streak = ref.read(streakProvider);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('Workout completed'),
        content: Text(
          'Nice work. You’re on a ${streak.currentStreak}-day streak. '
          'See you tomorrow.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _CoachNudgeCard extends ConsumerWidget {
  const _CoachNudgeCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nudge = ref.watch(coachNudgeProvider);
    final theme = Theme.of(context);

    return nudge.when(
      loading: () => const SkeletonBox(height: 88),
      error: (_, _) => AppCard(
        borderColor: AppColors.mist,
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Coach is unavailable right now.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                ),
              ),
            ),
            TextButton(
              onPressed: () => ref.invalidate(coachNudgeProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (text) {
        if (text.isEmpty) return const SizedBox.shrink();
        return AppCard(
          borderColor: AppColors.mist,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppColors.forest,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coach',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.forestDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DoneForToday extends StatelessWidget {
  const _DoneForToday({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.successBgStart, AppColors.successBgEnd],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 48,
              color: AppColors.forest,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "You're done for today",
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.forestDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            streak > 0
                ? 'Nice work — $streak-day streak.'
                : 'Nice work.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.muted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Rest up — a new workout waits tomorrow.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.muted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StreakBanner extends StatelessWidget {
  const _StreakBanner({
    required this.streak,
    required this.freezes,
    required this.workoutDoneToday,
  });

  final int streak;
  final int freezes;
  final bool workoutDoneToday;

  String get _subtitle {
    if (freezes > 0) {
      return '$freezes streak freeze${freezes == 1 ? '' : 's'} ready';
    }
    if (workoutDoneToday) {
      return 'Show up tomorrow to keep it alive';
    }
    return 'Show up today to keep it alive';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$streak day streak. $_subtitle',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.streakBgStart, AppColors.streakBgEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(Icons.local_fire_department, color: AppColors.streak, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$streak day streak',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.streak,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    _subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.item,
    required this.enabled,
    required this.onComplete,
  });

  final WorkoutExercise item;
  final bool enabled;
  final ValueChanged<int> onComplete;

  @override
  Widget build(BuildContext context) {
    final def = ExerciseLibrary.byId(item.exerciseId);
    final theme = Theme.of(context);

    return Material(
      color: item.done ? AppColors.mist : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: !enabled
            ? null
            : () => _showCompleteSheet(context, def, item, onComplete),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                item.done ? Icons.check_circle : Icons.circle_outlined,
                color: item.done ? AppColors.forest : AppColors.muted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(def.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      item.done && item.completed != null
                          ? 'Did ${def.unit.format(item.completed!)} · target ${def.unit.format(item.target)}'
                          : def.cue,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!item.done)
                      Text(
                        'Target ${def.unit.format(item.target)}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.forest,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              if (enabled)
                Text(
                  item.done ? 'Edit' : 'Log',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.forest,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCompleteSheet(
    BuildContext context,
    ExerciseDefinition def,
    WorkoutExercise item,
    ValueChanged<int> onComplete,
  ) async {
    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _LogExerciseSheet(def: def, item: item),
    );

    if (result != null) onComplete(result);
  }
}

class _LogExerciseSheet extends StatefulWidget {
  const _LogExerciseSheet({required this.def, required this.item});

  final ExerciseDefinition def;
  final WorkoutExercise item;

  @override
  State<_LogExerciseSheet> createState() => _LogExerciseSheetState();
}

class _LogExerciseSheetState extends State<_LogExerciseSheet> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = widget.item.completed ?? widget.item.target;
    _controller = TextEditingController(text: '$initial');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final v = int.tryParse(_controller.text.trim());
    if (v == null || v < 0) {
      setState(() => _error = 'Enter a valid number (0 or more).');
      return;
    }
    final max = widget.def.unit == ExerciseUnit.seconds
        ? InputLimits.maxSeconds
        : InputLimits.maxReps;
    if (v > max) {
      setState(() => _error = 'Max is $max for this exercise.');
      return;
    }
    Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) {
    final def = widget.def;
    final item = widget.item;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(def.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              def.howTo,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                    height: 1.45,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Target: ${def.unit.format(item.target)}. '
              'Enter what you actually completed.',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.forestDark,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: def.unit == ExerciseUnit.seconds
                    ? 'Seconds completed'
                    : 'Reps completed',
                errorText: _error,
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, item.target),
                    child: const Text('Hit target'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
