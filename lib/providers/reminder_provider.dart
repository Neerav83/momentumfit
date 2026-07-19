import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentumfit/l10n/app_localizations.dart';

import '../data/notifications/notification_service.dart';
import '../domain/models/reminder_settings.dart';
import '../domain/services/streak_service.dart';
import 'app_providers.dart';
import 'locale_provider.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final reminderSettingsProvider =
    NotifierProvider<ReminderSettingsNotifier, ReminderSettings>(
  ReminderSettingsNotifier.new,
);

class ReminderSettingsNotifier extends Notifier<ReminderSettings> {
  @override
  ReminderSettings build() {
    return ref.read(localAppStoreProvider).readReminderSettings();
  }

  bool get _workoutDoneToday {
    final today = StreakService.dateOnly(DateTime.now());
    return ref.read(localAppStoreProvider).readWorkouts().any(
          (w) => StreakService.isSameDay(w.date, today) && w.isCompleted,
        );
  }

  AppLocalizations get _l10n {
    final preferred = ref.read(localeProvider);
    final code = preferred?.languageCode ??
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return lookupAppLocalizations(
      code == 'sv' ? const Locale('sv') : const Locale('en'),
    );
  }

  Future<void> _sync(ReminderSettings settings) async {
    await ref.read(notificationServiceProvider).syncSchedule(
          settings,
          skipToday: _workoutDoneToday,
          l10n: _l10n,
        );
  }

  Future<String?> setEnabled(bool enabled) async {
    final service = ref.read(notificationServiceProvider);
    await service.initialize();

    if (enabled) {
      final granted = await service.requestPermission();
      if (!granted) {
        return _l10n.notificationsPermissionDenied;
      }
    }

    final updated = state.copyWith(enabled: enabled);
    await ref.read(localAppStoreProvider).writeReminderSettings(updated);
    await _sync(updated);
    state = updated;
    return null;
  }

  Future<void> setTime({required int hour, required int minute}) async {
    final updated = state.copyWith(hour: hour, minute: minute);
    await ref.read(localAppStoreProvider).writeReminderSettings(updated);
    await _sync(updated);
    state = updated;
  }

  Future<void> rescheduleFromDisk() async {
    final settings = ref.read(localAppStoreProvider).readReminderSettings();
    state = settings;
    final service = ref.read(notificationServiceProvider);
    await service.initialize();
    await _sync(settings);
  }

  /// Call after today's workout is finished so today's reminder is skipped.
  Future<void> onWorkoutCompleted() async {
    if (!state.enabled) return;
    await _sync(state);
  }

  /// Cancel scheduled notifications and restore defaults (e.g. on full reset).
  Future<void> clearOnReset() async {
    final service = ref.read(notificationServiceProvider);
    await service.initialize();
    await service.cancelDaily();
    state = ReminderSettings.defaults;
  }
}
