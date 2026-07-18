import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:momentumfit/data/local/local_app_store.dart';
import 'package:momentumfit/domain/models/avatar.dart';
import 'package:momentumfit/domain/models/enums.dart';
import 'package:momentumfit/domain/models/user_profile.dart';
import 'package:momentumfit/providers/app_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('completeAssessment saves levels without circular dependency', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = LocalAppStore.forTesting(prefs);
    await store.initialize();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        localAppStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(container.dispose);

    await container.read(profileProvider.notifier).completeOnboarding(
          UserProfile(
            name: 'Test',
            avatarId: AvatarOption.fox.id,
            age: 28,
            heightCm: 175,
            weightKg: 75,
            activityLevel: ActivityLevel.beginner,
            injuries: {Injury.none},
            onboardingCompleted: true,
            assessmentCompleted: false,
            createdAt: DateTime.now(),
          ),
        );

    await container.read(profileProvider.notifier).completeAssessment({
      'push_ups': 10,
      'squats': 20,
      'plank': 40,
    });

    final profile = container.read(profileProvider);
    expect(profile?.assessmentCompleted, isTrue);
    expect(container.read(levelsProvider), isNotEmpty);
  });
}
