// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'MomentumFit';

  @override
  String get appTagline => 'Become a little stronger every day.';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get settings => 'Settings';

  @override
  String get navToday => 'Today';

  @override
  String get reminders => 'Reminders';

  @override
  String get aiCoach => 'AI Coach';

  @override
  String get training => 'Training';

  @override
  String get dangerZone => 'Danger zone';

  @override
  String get language => 'Language';

  @override
  String get dailyReminder => 'Daily reminder';

  @override
  String get dailyReminderDescription => 'Get a nudge so you don\'t miss a day';

  @override
  String dailyReminderEnabled(String time) {
    return 'Local notification at $time';
  }

  @override
  String get reminderTime => 'Reminder time';

  @override
  String get personalizedAiNudges => 'Personalized AI nudges';

  @override
  String get aiConsentEnabled =>
      'Workout stats may be sent to the coach service. Name and injuries stay private.';

  @override
  String get aiConsentDisabled =>
      'Uses calm offline tips only — nothing leaves your device.';

  @override
  String get retakeAssessment => 'Retake assessment';

  @override
  String get retakeAssessmentSubtitle => 'Recommended every 4 weeks';

  @override
  String get retakeAssessmentDialogTitle => 'Retake assessment?';

  @override
  String get retakeAssessmentDialogBody =>
      'Your current exercise targets will be recalculated from a new fitness check.';

  @override
  String get cancel => 'Cancel';

  @override
  String get continueAction => 'Continue';

  @override
  String ageYears(int age) {
    return '$age yrs';
  }

  @override
  String get defaultFriendName => 'Friend';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get notificationsPermissionDenied =>
      'Notifications permission was denied. Enable it in system settings.';

  @override
  String get reminderNotificationTitle => 'Your streak is waiting';

  @override
  String get reminderNotificationBody =>
      'Today\'s workout is ready. A few minutes is enough.';

  @override
  String get reminderChannelName => 'Daily reminders';

  @override
  String get reminderChannelDescription =>
      'Daily MomentumFit workout reminders';

  @override
  String get resetAllData => 'Reset all data';

  @override
  String get resetAllDataSubtitle => 'Clears profile, streaks and history';

  @override
  String get resetDialogTitle => 'Reset everything?';

  @override
  String get resetDialogBody =>
      'This cannot be undone. You\'ll go through onboarding again.';

  @override
  String get reset => 'Reset';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSwedish => 'Svenska';

  @override
  String get todaysWorkout => 'Today\'s workout';

  @override
  String get todaysWorkoutSubtitle => 'Just a few moves. Keep it easy.';

  @override
  String get noWorkoutYet => 'No workout yet.';

  @override
  String get logExercisePrompt =>
      'Log every exercise to finish today\'s workout.';

  @override
  String get completeWorkout => 'Complete workout';

  @override
  String get youAreDoneForToday => 'You\'re done for today';

  @override
  String niceworkStreak(int streak) {
    return 'Nice work — $streak-day streak.';
  }

  @override
  String get nicework => 'Nice work.';

  @override
  String get restUpNewWorkoutTomorrow =>
      'Rest up — a new workout waits tomorrow.';

  @override
  String dayStreak(int count) {
    return '$count day streak';
  }

  @override
  String streakFreezesReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count streak freezes ready',
      one: '1 streak freeze ready',
    );
    return '$_temp0';
  }

  @override
  String get showUpTomorrowToKeepAlive => 'Show up tomorrow to keep it alive';

  @override
  String get showUpTodayToKeepAlive => 'Show up today to keep it alive';

  @override
  String get workoutCompleted => 'Workout completed';

  @override
  String workoutCompletedMessage(int streak) {
    return 'Nice work. You\'re on a $streak-day streak. See you tomorrow.';
  }

  @override
  String get done => 'Done';

  @override
  String get coach => 'Coach';

  @override
  String get coachUnavailable => 'Coach is unavailable right now.';

  @override
  String get retry => 'Retry';

  @override
  String didAndTarget(String completed, String target) {
    return 'Did $completed · target $target';
  }

  @override
  String target(String target) {
    return 'Target $target';
  }

  @override
  String get edit => 'Edit';

  @override
  String get log => 'Log';

  @override
  String targetEnterCompleted(String target) {
    return 'Target: $target. Enter what you actually completed.';
  }

  @override
  String get secondsCompleted => 'Seconds completed';

  @override
  String get repsCompleted => 'Reps completed';

  @override
  String get enterValidNumber => 'Enter a valid number (0 or more).';

  @override
  String maxForExercise(int max) {
    return 'Max is $max for this exercise.';
  }

  @override
  String get hitTarget => 'Hit target';

  @override
  String get save => 'Save';

  @override
  String get whoIsTraining => 'Who\'s training?';

  @override
  String get pickAvatarPrompt => 'Pick an avatar and tell us what to call you.';

  @override
  String get yourName => 'Your name';

  @override
  String get nameHint => 'Alex';

  @override
  String get chooseYourAvatar => 'Choose your avatar';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String stepOfTotal(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get aFewBasics => 'A few basics';

  @override
  String get aFewBasicsSubtitle => 'Helps us scale workouts gently to you.';

  @override
  String get age => 'Age';

  @override
  String get height => 'Height';

  @override
  String get weight => 'Weight';

  @override
  String heightCm(int value) {
    return '$value cm';
  }

  @override
  String weightKg(int value) {
    return '$value kg';
  }

  @override
  String get howActiveAreYou => 'How active are you?';

  @override
  String get howActiveSubtitle =>
      'We\'ll start easier than you think — on purpose.';

  @override
  String get activityLevelBeginner => 'Beginner';

  @override
  String get activityLevelBeginnerDesc => 'Just getting started';

  @override
  String get activityLevelSometimes => 'Sometimes active';

  @override
  String get activityLevelSometimesDesc => 'A few times a month';

  @override
  String get activityLevelRegular => 'Regularly active';

  @override
  String get activityLevelRegularDesc => 'Several times a week';

  @override
  String get anythingToAvoid => 'Anything to avoid?';

  @override
  String get anythingToAvoidSubtitle =>
      'Optional. We\'ll skip exercises that stress these areas.';

  @override
  String get injuryKnees => 'Knees';

  @override
  String get injuryBack => 'Back';

  @override
  String get injuryShoulders => 'Shoulders';

  @override
  String get injuryNone => 'None';

  @override
  String get injuryNoneDesc => 'No limitations';

  @override
  String get injuryAdaptWorkouts => 'Adapt workouts around this';

  @override
  String get fitnessCheck => 'Fitness check';

  @override
  String get fitnessCheckSubtitle =>
      'Instead of guessing what you can do — measure it. Take your time. Good form beats max effort.';

  @override
  String exerciseOfTotal(int current, int total) {
    return 'Exercise $current of $total';
  }

  @override
  String get seconds => 'Seconds';

  @override
  String get reps => 'Reps';

  @override
  String get secondsHint => 'sec';

  @override
  String get repsHint => 'reps';

  @override
  String get enterValidNumberSimple => 'Enter a valid number';

  @override
  String maxForExerciseSimple(int max) {
    return 'Max is $max for this exercise';
  }

  @override
  String get saveAndStart => 'Save & start';

  @override
  String get nextExercise => 'Next exercise';

  @override
  String get couldNotSaveAssessment =>
      'Could not save assessment. Please try again.';

  @override
  String get progress => 'Progress';

  @override
  String get progressSubtitle => 'Small gains, clearly visible.';

  @override
  String get streak => 'Streak';

  @override
  String get best => 'Best';

  @override
  String get workouts => 'Workouts';

  @override
  String get recentWorkouts => 'Recent workouts';

  @override
  String get completeWorkoutToSeeHistory =>
      'Complete a workout to see your history here.';

  @override
  String exercisesLogged(int count) {
    return '$count exercises logged';
  }

  @override
  String get achievements => 'Achievements';

  @override
  String get exerciseTargets => 'Exercise targets';

  @override
  String get completeAssessmentToStart =>
      'Complete your assessment to start tracking.';

  @override
  String targetValue(String value) {
    return 'Target $value';
  }

  @override
  String prValue(String value) {
    return 'PR $value';
  }

  @override
  String recentPerformanceChart(String name) {
    return 'Recent performance chart for $name';
  }

  @override
  String get achievementFirstStepTitle => 'First step';

  @override
  String get achievementFirstStepDesc => 'Complete your first workout';

  @override
  String get achievementThreeInRowTitle => 'Three in a row';

  @override
  String get achievementThreeInRowDesc => 'Reach a 3-day streak';

  @override
  String get achievementWeekOfMomentumTitle => 'Week of momentum';

  @override
  String get achievementWeekOfMomentumDesc => 'Reach a 7-day streak';

  @override
  String get achievementTenSessionsTitle => 'Ten sessions';

  @override
  String get achievementTenSessionsDesc => 'Complete 10 workouts';

  @override
  String get achievementSafetyNetTitle => 'Safety net';

  @override
  String get achievementSafetyNetDesc => 'Earn a streak freeze';

  @override
  String get exercisePushUps => 'Push-ups';

  @override
  String get exercisePushUpsCue => 'Chest to the floor with control.';

  @override
  String get exercisePushUpsHowTo =>
      'Start in a high plank with hands under your shoulders. Lower your chest toward the floor, keeping elbows close to your body, then press back up. Keep your body in a straight line from head to heels.';

  @override
  String get exerciseKneePushUps => 'Knee push-ups';

  @override
  String get exerciseKneePushUpsCue => 'Same as push-ups, from the knees.';

  @override
  String get exerciseKneePushUpsHowTo =>
      'Kneel on the floor and place your hands under your shoulders. Keep a straight line from knees to head. Lower your chest toward the floor, then press back up with control.';

  @override
  String get exerciseChairDips => 'Chair dips';

  @override
  String get exerciseChairDipsCue => 'Lower until elbows are near 90°.';

  @override
  String get exerciseChairDipsHowTo =>
      'Sit on the edge of a sturdy chair, hands beside your hips. Slide forward so your hips clear the seat. Bend your elbows to lower your body, then press up. Keep shoulders down and away from your ears.';

  @override
  String get exerciseSquats => 'Squats';

  @override
  String get exerciseSquatsCue => 'Sit back, chest up, heels down.';

  @override
  String get exerciseSquatsHowTo =>
      'Stand with feet about shoulder-width apart. Sit your hips back as if into a chair, keep your chest lifted, and lower until thighs are roughly parallel to the floor (or as deep as comfortable). Drive through your heels to stand.';

  @override
  String get exerciseLunges => 'Lunges';

  @override
  String get exerciseLungesCue => 'Alternate legs. Count every step.';

  @override
  String get exerciseLungesHowTo =>
      'Step one foot forward and bend both knees until the back knee nearly touches the floor. Keep your front knee above your ankle. Push back to standing and switch legs. Count total reps across both sides.';

  @override
  String get exerciseGluteBridge => 'Glute bridge';

  @override
  String get exerciseGluteBridgeCue => 'Squeeze at the top, then lower.';

  @override
  String get exerciseGluteBridgeHowTo =>
      'Lie on your back with knees bent and feet flat on the floor. Press through your heels to lift your hips until your body forms a straight line from shoulders to knees. Squeeze your glutes at the top, then lower slowly.';

  @override
  String get exerciseCalfRaises => 'Calf raises';

  @override
  String get exerciseCalfRaisesCue => 'Rise onto your toes, pause, lower.';

  @override
  String get exerciseCalfRaisesHowTo =>
      'Stand tall with feet hip-width apart. Rise onto the balls of your feet as high as you can, pause briefly, then lower with control. Hold a wall or chair for balance if needed.';

  @override
  String get exercisePlank => 'Plank';

  @override
  String get exercisePlankCue => 'Hold a straight line — no sagging.';

  @override
  String get exercisePlankHowTo =>
      'Place forearms on the floor with elbows under shoulders, or hold a high plank on your hands. Keep your body straight from head to heels. Brace your core, squeeze your glutes, and breathe steadily. Stop if your form breaks.';

  @override
  String get exerciseSidePlank => 'Side plank';

  @override
  String get exerciseSidePlankCue => 'Log the weaker side\'s time.';

  @override
  String get exerciseSidePlankHowTo =>
      'Lie on one side with your elbow under your shoulder. Lift your hips so your body forms a straight line. Hold, then switch sides. Log the time of your weaker side.';

  @override
  String get exerciseDeadBug => 'Dead bug';

  @override
  String get exerciseDeadBugCue => 'Slow moves, back pressed down.';

  @override
  String get exerciseDeadBugHowTo =>
      'Lie on your back with arms toward the ceiling and knees bent at 90°. Slowly extend opposite arm and leg toward the floor without letting your lower back arch. Return and switch sides. One rep = both sides once.';

  @override
  String get exerciseBirdDog => 'Bird dog';

  @override
  String get exerciseBirdDogCue => 'Opposite arm and leg, then switch.';

  @override
  String get exerciseBirdDogHowTo =>
      'Start on all fours with hands under shoulders and knees under hips. Extend one arm forward and the opposite leg back, keeping hips level. Pause, return, then switch. One rep = both sides once.';

  @override
  String get exerciseJumpingJacks => 'Jumping jacks';

  @override
  String get exerciseJumpingJacksCue => 'Steady rhythm, soft landings.';

  @override
  String get exerciseJumpingJacksHowTo =>
      'Stand with feet together and arms at your sides. Jump your feet out while raising your arms overhead, then jump back to the start. Land softly and keep a steady pace.';

  @override
  String get exerciseHighKnees => 'High knees';

  @override
  String get exerciseHighKneesCue => 'Drive knees up, stay light.';

  @override
  String get exerciseHighKneesHowTo =>
      'Jog in place while driving your knees up toward hip height. Pump your arms and stay on the balls of your feet. Count each knee drive as one rep.';

  @override
  String get exerciseMountainClimbers => 'Mountain climbers';

  @override
  String get exerciseMountainClimbersCue => 'Hips level as you switch legs.';

  @override
  String get exerciseMountainClimbersHowTo =>
      'Start in a high plank. Drive one knee toward your chest, then quickly switch legs as if running in place. Keep hips low and level. Count each knee drive as one rep.';

  @override
  String get exerciseUnknown => 'Unknown exercise';

  @override
  String get exerciseUnknownCue => 'This exercise is no longer in the catalog.';

  @override
  String get exerciseUnknownHowTo =>
      'Skip or re-take your assessment to refresh your plan.';
}
