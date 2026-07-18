import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:momentumfit/app.dart';
import 'package:momentumfit/domain/models/avatar.dart';
import 'package:momentumfit/domain/models/enums.dart';
import 'package:momentumfit/domain/models/user_profile.dart';
import 'package:momentumfit/providers/app_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('completing assessment navigates to home', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MomentumFitApp(),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MomentumFitApp)),
    );

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
    await tester.pumpAndSettle();

    expect(find.text('Fitness check'), findsOneWidget);

    // Push-ups
    await tester.enterText(find.byType(TextField), '10');
    await tester.tap(find.text('Next exercise'));
    await tester.pumpAndSettle();

    // Squats
    await tester.enterText(find.byType(TextField), '20');
    await tester.tap(find.text('Next exercise'));
    await tester.pumpAndSettle();

    // Plank
    await tester.enterText(find.byType(TextField), '40');
    await tester.tap(find.text('Save & start'));
    await tester.pumpAndSettle();

    expect(find.text("Today's workout"), findsOneWidget);
  });
}
