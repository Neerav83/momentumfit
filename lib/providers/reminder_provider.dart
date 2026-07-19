import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notifications/notification_service.dart';
import '../domain/models/reminder_settings.dart';
import '../domain/services/streak_service.dart';
import 'app_providers.dart';

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

  Future<void> _sync(ReminderSettings settings) async {
    await ref.read(notificationServiceProvider).syncSchedule(
          settings,
          skipToday: _workoutDoneToday,
        );
  }

  Future<String?> setEnabled(bool enabled) async {
    final service = ref.read(notificationServiceProvider);
    await service.initialize();

    if (enabled) {
      final granted = await service.requestPermission();
      if (!granted) {
        return 'Notifications permission was denied. Enable it in system settings.';
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
