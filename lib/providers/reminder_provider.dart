import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notifications/notification_service.dart';
import '../domain/models/reminder_settings.dart';
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
    await service.syncSchedule(updated);
    state = updated;
    return null;
  }

  Future<void> setTime({required int hour, required int minute}) async {
    final updated = state.copyWith(hour: hour, minute: minute);
    await ref.read(localAppStoreProvider).writeReminderSettings(updated);
    await ref.read(notificationServiceProvider).syncSchedule(updated);
    state = updated;
  }

  Future<void> rescheduleFromDisk() async {
    final settings = ref.read(localAppStoreProvider).readReminderSettings();
    state = settings;
    final service = ref.read(notificationServiceProvider);
    await service.initialize();
    await service.syncSchedule(settings);
  }
}
