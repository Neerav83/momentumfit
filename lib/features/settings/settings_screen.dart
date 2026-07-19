import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_states.dart';
import '../../domain/models/avatar.dart';
import '../../providers/app_providers.dart';
import '../../providers/coach_consent_provider.dart';
import '../../providers/coach_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/reminder_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(profileProvider);
    final reminder = ref.watch(reminderSettingsProvider);
    final aiConsent = ref.watch(coachAiConsentProvider);
    final currentLocale = ref.watch(localeProvider);

    if (profile == null) {
      return const LoadingScaffold();
    }

    final avatar = AvatarOption.fromId(profile.avatarId);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            Text(l10n.settings, style: theme.textTheme.headlineMedium),
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
            Text(l10n.language, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Column(
                children: [
                  RadioListTile<Locale?>(
                    contentPadding: const EdgeInsets.only(right: 8),
                    title: Text(
                      l10n.languageSystemDefault,
                      style: theme.textTheme.titleMedium,
                    ),
                    value: null,
                    groupValue: currentLocale,
                    activeColor: AppColors.forest,
                    onChanged: (value) {
                      ref.read(localeProvider.notifier).setLocale(value);
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<Locale?>(
                    contentPadding: const EdgeInsets.only(right: 8),
                    title: Text(
                      l10n.languageEnglish,
                      style: theme.textTheme.titleMedium,
                    ),
                    value: const Locale('en'),
                    groupValue: currentLocale,
                    activeColor: AppColors.forest,
                    onChanged: (value) {
                      ref.read(localeProvider.notifier).setLocale(value);
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<Locale?>(
                    contentPadding: const EdgeInsets.only(right: 8),
                    title: Text(
                      l10n.languageSwedish,
                      style: theme.textTheme.titleMedium,
                    ),
                    value: const Locale('sv'),
                    groupValue: currentLocale,
                    activeColor: AppColors.forest,
                    onChanged: (value) {
                      ref.read(localeProvider.notifier).setLocale(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.reminders, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.only(right: 8),
                    title: Text(
                      l10n.dailyReminder,
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      reminder.enabled
                          ? l10n.dailyReminderEnabled(reminder.formattedTime)
                          : l10n.dailyReminderDescription,
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
                        l10n.reminderTime,
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
            Text(l10n.aiCoach, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.only(right: 8),
                title: Text(
                  l10n.personalizedAiNudges,
                  style: theme.textTheme.titleMedium,
                ),
                subtitle: Text(
                  aiConsent
                      ? l10n.aiConsentEnabled
                      : l10n.aiConsentDisabled,
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
            Text(l10n.training, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.fitness_center_outlined,
              title: l10n.retakeAssessment,
              subtitle: l10n.retakeAssessmentSubtitle,
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.retakeAssessmentDialogTitle),
                    content: Text(l10n.retakeAssessmentDialogBody),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l10n.cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(l10n.continue),
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
            Text(l10n.dangerZone, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.delete_outline,
              title: l10n.resetAllData,
              subtitle: l10n.resetAllDataSubtitle,
              destructive: true,
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.resetDialogTitle),
                    content: Text(l10n.resetDialogBody),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l10n.cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(l10n.reset),
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
