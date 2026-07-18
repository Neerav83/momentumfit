import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/workout.dart';
import '../../providers/app_providers.dart';

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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: workoutAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Something went wrong: $e')),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_greeting()}, ${profile.name}',
                            style: theme.textTheme.headlineSmall,
                          ),
                          Text(
                            'Become a little stronger every day.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _StreakBanner(
                  streak: streak.currentStreak,
                  freezes: streak.freezeCount,
                ),
                const SizedBox(height: 28),
                Text(
                  done ? 'Workout complete' : "Today's workout",
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  done
                      ? 'Nice work. See you tomorrow.'
                      : 'Just a few moves. Keep it easy.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 20),
                if (workout == null)
                  const Text('No workout yet.')
                else ...[
                  for (var i = 0; i < workout.exercises.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ExerciseRow(
                        item: workout.exercises[i],
                        enabled: !done,
                        onComplete: (completed) {
                          ref
                              .read(todaysWorkoutProvider.notifier)
                              .markExercise(index: i, completed: completed);
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (!done)
                    FilledButton(
                      onPressed: workout.allMarked
                          ? () async {
                              await ref
                                  .read(todaysWorkoutProvider.notifier)
                                  .finishWorkout();
                              if (context.mounted) {
                                _showCompletionDialog(context, ref);
                              }
                            }
                          : null,
                      child: const Text('Complete workout'),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.mist,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Streak: ${streak.currentStreak} day${streak.currentStreak == 1 ? '' : 's'}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.forestDark,
                        ),
                      ),
                    ),
                ],
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '✅',
                style: TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 20),
              Text(
                'Workout completed!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.forestDark,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Great job! You\'re on a ${streak.currentStreak} day streak 🔥',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.muted,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'See you tomorrow!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.forest,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakBanner extends StatelessWidget {
  const _StreakBanner({required this.streak, required this.freezes});

  final int streak;
  final int freezes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7ED), Color(0xFFFEF3C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 28)),
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
                  freezes > 0
                      ? '$freezes streak freeze${freezes == 1 ? '' : 's'} ready'
                      : 'Show up today to keep it alive',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
        onTap: !enabled || item.done
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
                    Text(
                      item.done && item.completed != null
                          ? 'Did ${def.unit.format(item.completed!)} · target ${def.unit.format(item.target)}'
                          : 'Target ${def.unit.format(item.target)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (!item.done && enabled)
                Text(
                  'Log',
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
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.item.target}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(def.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            'Target: ${def.unit.format(item.target)}. '
            'Enter what you actually completed.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: def.unit == ExerciseUnit.seconds
                  ? 'Seconds completed'
                  : 'Reps completed',
            ),
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
                  onPressed: () {
                    final v = int.tryParse(_controller.text.trim());
                    if (v == null || v < 0) return;
                    Navigator.pop(context, v);
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
