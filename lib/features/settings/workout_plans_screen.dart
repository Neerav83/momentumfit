import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../providers/custom_plans_provider.dart';

class WorkoutPlansScreen extends ConsumerWidget {
  const WorkoutPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final plans = ref.watch(customPlansProvider);
    final activePlanAsync = ref.watch(activePlanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Träningsplaner'),
      ),
      body: plans.isEmpty
          ? _buildEmptyState(context)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (activePlanAsync.hasValue && activePlanAsync.value == null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AppCard(
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Ingen aktiv plan. Dagliga pass genereras automatiskt.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ...plans.map((plan) {
                  final isActive = activePlanAsync.value?.id == plan.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PlanCard(
                      plan: plan,
                      isActive: isActive,
                      onActivate: () async {
                        if (isActive) {
                          await ref
                              .read(customPlansProvider.notifier)
                              .setActivePlan(null);
                        } else {
                          await ref
                              .read(customPlansProvider.notifier)
                              .setActivePlan(plan.id);
                        }
                      },
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Ta bort plan?'),
                            content: Text(
                              'Är du säker på att du vill ta bort "${plan.name}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Avbryt'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Ta bort'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref
                              .read(customPlansProvider.notifier)
                              .deletePlan(plan.id);
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_note,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Inga träningsplaner ännu',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Skapa en plan genom att diskutera med AI-coachen i Träningsplaneraren',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isActive,
    required this.onActivate,
    required this.onDelete,
  });

  final plan;
  final bool isActive;
  final VoidCallback onActivate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            plan.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.forest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'AKTIV',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (plan.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        plan.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
                tooltip: 'Ta bort',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Veckoschema:',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          ...plan.weeklySchedule.map((day) {
            final dayName = _getDayName(day.dayOfWeek);
            final info = day.isRestDay
                ? 'Vilodag'
                : '${day.exercises.length} övningar';
            return Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '$dayName: $info',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.ink.withOpacity(0.8),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onActivate,
              icon: Icon(isActive ? Icons.close : Icons.check),
              label: Text(isActive ? 'Inaktivera' : 'Aktivera'),
              style: FilledButton.styleFrom(
                backgroundColor:
                    isActive ? AppColors.muted : AppColors.forest,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Mån';
      case 2:
        return 'Tis';
      case 3:
        return 'Ons';
      case 4:
        return 'Tor';
      case 5:
        return 'Fre';
      case 6:
        return 'Lör';
      case 7:
        return 'Sön';
      default:
        return 'Dag $dayOfWeek';
    }
  }
}
