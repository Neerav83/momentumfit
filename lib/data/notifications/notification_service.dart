import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:momentumfit/l10n/app_localizations.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/models/reminder_settings.dart';

/// Local (on-device) reminders — no Apple Push / server required.
class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _dailyId = 1001;
  static const _channelId = 'momentum_daily';

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      try {
        tz.setLocalLocation(tz.getLocation('Europe/Stockholm'));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: ios,
        macOS: ios,
      ),
    );

    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      if (granted == false) return false;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    final mac = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    if (mac != null) {
      final granted = await mac.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Schedules the daily reminder.
  ///
  /// When [skipToday] is true (workout already done), the next fire is
  /// tomorrow even if today's reminder time has not passed yet.
  Future<void> syncSchedule(
    ReminderSettings settings, {
    bool skipToday = false,
    required AppLocalizations l10n,
  }) async {
    await initialize();
    await cancelDaily();

    if (!settings.enabled) return;

    final when = _nextInstance(
      settings.hour,
      settings.minute,
      skipToday: skipToday,
    );

    await _plugin.zonedSchedule(
      id: _dailyId,
      title: l10n.reminderNotificationTitle,
      body: l10n.reminderNotificationBody,
      scheduledDate: when,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          l10n.reminderChannelName,
          channelDescription: l10n.reminderChannelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
        macOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    if (kDebugMode) {
      debugPrint(
        'Scheduled daily reminder at ${settings.formattedTime} '
        '(next=$when, skipToday=$skipToday, tz=${tz.local.name})',
      );
    }
  }

  Future<void> cancelDaily() async {
    await _plugin.cancel(id: _dailyId);
  }

  tz.TZDateTime _nextInstance(
    int hour,
    int minute, {
    bool skipToday = false,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (skipToday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
