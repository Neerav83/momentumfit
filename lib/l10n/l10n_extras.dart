import 'package:momentumfit/l10n/app_localizations.dart';

import '../domain/models/exercise.dart';

extension ExerciseL10n on ExerciseDefinition {
  String nameOf(AppLocalizations l10n) => switch (id) {
        'push_ups' => l10n.exercisePushUps,
        'knee_push_ups' => l10n.exerciseKneePushUps,
        'chair_dips' => l10n.exerciseChairDips,
        'squats' => l10n.exerciseSquats,
        'lunges' => l10n.exerciseLunges,
        'glute_bridge' => l10n.exerciseGluteBridge,
        'calf_raises' => l10n.exerciseCalfRaises,
        'plank' => l10n.exercisePlank,
        'side_plank' => l10n.exerciseSidePlank,
        'dead_bug' => l10n.exerciseDeadBug,
        'bird_dog' => l10n.exerciseBirdDog,
        'jumping_jacks' => l10n.exerciseJumpingJacks,
        'high_knees' => l10n.exerciseHighKnees,
        'mountain_climbers' => l10n.exerciseMountainClimbers,
        _ => l10n.exerciseUnknown,
      };

  String cueOf(AppLocalizations l10n) => switch (id) {
        'push_ups' => l10n.exercisePushUpsCue,
        'knee_push_ups' => l10n.exerciseKneePushUpsCue,
        'chair_dips' => l10n.exerciseChairDipsCue,
        'squats' => l10n.exerciseSquatsCue,
        'lunges' => l10n.exerciseLungesCue,
        'glute_bridge' => l10n.exerciseGluteBridgeCue,
        'calf_raises' => l10n.exerciseCalfRaisesCue,
        'plank' => l10n.exercisePlankCue,
        'side_plank' => l10n.exerciseSidePlankCue,
        'dead_bug' => l10n.exerciseDeadBugCue,
        'bird_dog' => l10n.exerciseBirdDogCue,
        'jumping_jacks' => l10n.exerciseJumpingJacksCue,
        'high_knees' => l10n.exerciseHighKneesCue,
        'mountain_climbers' => l10n.exerciseMountainClimbersCue,
        _ => l10n.exerciseUnknownCue,
      };

  String howToOf(AppLocalizations l10n) => switch (id) {
        'push_ups' => l10n.exercisePushUpsHowTo,
        'knee_push_ups' => l10n.exerciseKneePushUpsHowTo,
        'chair_dips' => l10n.exerciseChairDipsHowTo,
        'squats' => l10n.exerciseSquatsHowTo,
        'lunges' => l10n.exerciseLungesHowTo,
        'glute_bridge' => l10n.exerciseGluteBridgeHowTo,
        'calf_raises' => l10n.exerciseCalfRaisesHowTo,
        'plank' => l10n.exercisePlankHowTo,
        'side_plank' => l10n.exerciseSidePlankHowTo,
        'dead_bug' => l10n.exerciseDeadBugHowTo,
        'bird_dog' => l10n.exerciseBirdDogHowTo,
        'jumping_jacks' => l10n.exerciseJumpingJacksHowTo,
        'high_knees' => l10n.exerciseHighKneesHowTo,
        'mountain_climbers' => l10n.exerciseMountainClimbersHowTo,
        _ => l10n.exerciseUnknownHowTo,
      };
}

({String title, String description}) achievementLabels(
  String id,
  AppLocalizations l10n,
) {
  return switch (id) {
    'first_workout' => (
        title: l10n.achievementFirstStepTitle,
        description: l10n.achievementFirstStepDesc,
      ),
    'streak_3' => (
        title: l10n.achievementThreeInRowTitle,
        description: l10n.achievementThreeInRowDesc,
      ),
    'streak_7' => (
        title: l10n.achievementWeekOfMomentumTitle,
        description: l10n.achievementWeekOfMomentumDesc,
      ),
    'workouts_10' => (
        title: l10n.achievementTenSessionsTitle,
        description: l10n.achievementTenSessionsDesc,
      ),
    'freeze_earned' => (
        title: l10n.achievementSafetyNetTitle,
        description: l10n.achievementSafetyNetDesc,
      ),
    _ => (title: id, description: ''),
  };
}
