class ReminderSettings {
  const ReminderSettings({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  final bool enabled;
  final int hour;
  final int minute;

  static const defaults = ReminderSettings(
    enabled: false,
    hour: 18,
    minute: 0,
  );

  TimeOfDayCompat get time => TimeOfDayCompat(hour: hour, minute: minute);

  String get formattedTime {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  ReminderSettings copyWith({
    bool? enabled,
    int? hour,
    int? minute,
  }) {
    return ReminderSettings(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'hour': hour,
        'minute': minute,
      };

  factory ReminderSettings.fromJson(Map<String, dynamic> json) {
    return ReminderSettings(
      enabled: json['enabled'] as bool? ?? false,
      hour: json['hour'] as int? ?? 18,
      minute: json['minute'] as int? ?? 0,
    );
  }
}

/// Avoid importing Flutter in domain-ish models for formatting helpers.
class TimeOfDayCompat {
  const TimeOfDayCompat({required this.hour, required this.minute});
  final int hour;
  final int minute;
}
