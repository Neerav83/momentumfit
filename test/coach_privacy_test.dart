import 'package:flutter_test/flutter_test.dart';
import 'package:momentumfit/domain/models/enums.dart';
import 'package:momentumfit/domain/models/user_profile.dart';
import 'package:momentumfit/domain/models/workout.dart';
import 'package:momentumfit/domain/services/coach_insights.dart';

void main() {
  test('redacts name and injuries unless private details are opted in', () {
    final profile = UserProfile(
      name: 'Alex',
      avatarId: 'fox',
      age: 30,
      heightCm: 175,
      weightKg: 70,
      activityLevel: ActivityLevel.beginner,
      injuries: {Injury.shoulders},
      onboardingCompleted: true,
      assessmentCompleted: true,
      createdAt: DateTime(2026, 1, 1),
    );

    final insights = CoachInsightBuilder.build(
      profile: profile,
      streak: const StreakState(currentStreak: 3, longestStreak: 3),
      workout: null,
      history: const [],
      levels: const {},
    );

    final publicFacts = insights.factsForPrompt();
    expect(publicFacts.any((f) => f.startsWith('Name:')), isFalse);
    expect(publicFacts.any((f) => f.startsWith('Injuries:')), isFalse);
    expect(publicFacts.any((f) => f.startsWith('Current streak:')), isTrue);

    final privateFacts = insights.factsForPrompt(includePrivateDetails: true);
    expect(privateFacts.any((f) => f.startsWith('Name: Alex')), isTrue);
    expect(privateFacts.any((f) => f.startsWith('Injuries:')), isTrue);
  });
}
