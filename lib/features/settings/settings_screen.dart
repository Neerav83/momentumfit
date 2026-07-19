import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_states.dart';
import '../../domain/models/avatar.dart';
import '../../providers/app_providers.dart';
import '../../providers/coach_consent_provider.dart';
import '../../providers/coach_provider.dart';
import '../../providers/reminder_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(profileProvider);
    final reminder = ref.watch(reminderSettingsProvider);
    final aiConsent = ref.watch(coachAiConsentProvider);

    if (profile == null) {
      return const LoadingScaffold();
    }

    final avatar = AvatarOption.fromId(profile.avatarId);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            Text('Settings', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 24),
            AppCard(
              child: Row(
                children: [
                  Text(avatar.emoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.name, style: theme.textTheme.titleLarge),
                        Text(
                          '${profile.activityLevel.label} · ${profile.age} yrs',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Reminders', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.only(right: 8),
                    title: Text(
                      'Daily reminder',
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      reminder.enabled
                          ? 'Local notification at ${reminder.formattedTime}'
                          : 'Get a nudge so you don’t miss a day',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                    value: reminder.enabled,
                    activeThumbColor: AppColors.forest,
                    onChanged: (value) async {
                      final error = await ref
                          .read(reminderSettingsProvider.notifier)
                          .setEnabled(value);
                      if (error != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error)),
                        );
                      }
                    },
                  ),
                  if (reminder.enabled) ...[
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: const EdgeInsets.only(right: 8),
                      title: Text(
                        'Reminder time',
                        style: theme.textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        reminder.formattedTime,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.schedule,
                        color: AppColors.forest,
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: reminder.hour,
                            minute: reminder.minute,
                          ),
                        );
                        if (picked == null) return;
                        await ref
                            .read(reminderSettingsProvider.notifier)
                            .setTime(
                              hour: picked.hour,
                              minute: picked.minute,
                            );
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('AI Coach', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.only(right: 8),
                title: Text(
                  'Personalized AI nudges',
                  style: theme.textTheme.titleMedium,
                ),
                subtitle: Text(
                  aiConsent
                      ? 'Workout stats may be sent to the coach service. Name and injuries stay private.'
                      : 'Uses calm offline tips only — nothing leaves your device.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                value: aiConsent,
                activeThumbColor: AppColors.forest,
                onChanged: (value) async {
                  await ref
                      .read(coachAiConsentProvider.notifier)
                      .setConsented(value);
                  ref.invalidate(coachNudgeProvider);
                },
              ),
            ),
            const SizedBox(height: 24),
            Text('Training', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.fitness_center_outlined,
              title: 'Retake assessment',
              subtitle: 'Recommended every 4 weeks',
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Retake assessment?'),
                    content: const Text(
                      'Your current exercise targets will be recalculated from a new fitness check.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Continue'),
                      ),
                    ],
                  ),
                );
                if (ok != true) return;
                final updated = profile.copyWith(
                  assessmentCompleted: false,
                );
                await ref.read(profileProvider.notifier).save(updated);
                if (context.mounted) context.go('/assessment');
              },
            ),
            const SizedBox(height: 24),
            Text('Danger zone', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.delete_outline,
              title: 'Reset all data',
              subtitle: 'Clears profile, streaks and history',
              destructive: true,
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Reset everything?'),
                    content: const Text(
                      'This cannot be undone. You’ll go through onboarding again.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  await ref.read(reminderSettingsProvider.notifier).clearOnReset();
                  await ref.read(profileProvider.notifier).reset();
                  ref.read(coachAiConsentProvider.notifier).refresh();
                  ref.invalidate(coachNudgeProvider);
                }
              },
            ),
            const SizedBox(height: 32),
            Text(
              'MomentumFit',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.danger : AppColors.ink;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: color,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.muted,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
