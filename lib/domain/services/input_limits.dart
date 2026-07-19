/// Shared clamps for user-entered workout / assessment values.
abstract final class InputLimits {
  static const maxNameLength = 40;
  static const maxReps = 500;
  static const maxSeconds = 600;

  static int clampReps(int value) => value.clamp(0, maxReps);

  static int clampSeconds(int value) => value.clamp(0, maxSeconds);

  static int clampByUnitName(int value, String unitName) {
    if (unitName == 'seconds') return clampSeconds(value);
    return clampReps(value);
  }

  static String clampName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Friend';
    if (trimmed.length <= maxNameLength) return trimmed;
    return trimmed.substring(0, maxNameLength);
  }
}
