import 'package:flutter_test/flutter_test.dart';
import 'package:momentumfit/domain/services/input_limits.dart';

void main() {
  group('InputLimits', () {
    test('clamps reps and seconds', () {
      expect(InputLimits.clampReps(-1), 0);
      expect(InputLimits.clampReps(9999), InputLimits.maxReps);
      expect(InputLimits.clampSeconds(900), InputLimits.maxSeconds);
    });

    test('clamps name length and empty fallback', () {
      expect(InputLimits.clampName('  '), 'Friend');
      expect(InputLimits.clampName('Alex'), 'Alex');
      expect(
        InputLimits.clampName('A' * 100).length,
        InputLimits.maxNameLength,
      );
    });
  });
}
