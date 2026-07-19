import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sv.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sv'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'MomentumFit'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Become a little stronger every day.'**
  String get appTagline;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @aiCoach.
  ///
  /// In en, this message translates to:
  /// **'AI Coach'**
  String get aiCoach;

  /// No description provided for @training.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get training;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get dangerZone;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get dailyReminder;

  /// No description provided for @dailyReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Get a nudge so you don\'t miss a day'**
  String get dailyReminderDescription;

  /// No description provided for @dailyReminderEnabled.
  ///
  /// In en, this message translates to:
  /// **'Local notification at {time}'**
  String dailyReminderEnabled(String time);

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// No description provided for @personalizedAiNudges.
  ///
  /// In en, this message translates to:
  /// **'Personalized AI nudges'**
  String get personalizedAiNudges;

  /// No description provided for @aiConsentEnabled.
  ///
  /// In en, this message translates to:
  /// **'Workout stats may be sent to the coach service. Name and injuries stay private.'**
  String get aiConsentEnabled;

  /// No description provided for @aiConsentDisabled.
  ///
  /// In en, this message translates to:
  /// **'Uses calm offline tips only — nothing leaves your device.'**
  String get aiConsentDisabled;

  /// No description provided for @retakeAssessment.
  ///
  /// In en, this message translates to:
  /// **'Retake assessment'**
  String get retakeAssessment;

  /// No description provided for @retakeAssessmentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended every 4 weeks'**
  String get retakeAssessmentSubtitle;

  /// No description provided for @retakeAssessmentDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Retake assessment?'**
  String get retakeAssessmentDialogTitle;

  /// No description provided for @retakeAssessmentDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Your current exercise targets will be recalculated from a new fitness check.'**
  String get retakeAssessmentDialogBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'{age} yrs'**
  String ageYears(int age);

  /// No description provided for @defaultFriendName.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get defaultFriendName;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @notificationsPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications permission was denied. Enable it in system settings.'**
  String get notificationsPermissionDenied;

  /// No description provided for @reminderNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Your streak is waiting'**
  String get reminderNotificationTitle;

  /// No description provided for @reminderNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Today\'s workout is ready. A few minutes is enough.'**
  String get reminderNotificationBody;

  /// No description provided for @reminderChannelName.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders'**
  String get reminderChannelName;

  /// No description provided for @reminderChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Daily MomentumFit workout reminders'**
  String get reminderChannelDescription;

  /// No description provided for @resetAllData.
  ///
  /// In en, this message translates to:
  /// **'Reset all data'**
  String get resetAllData;

  /// No description provided for @resetAllDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clears profile, streaks and history'**
  String get resetAllDataSubtitle;

  /// No description provided for @resetDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset everything?'**
  String get resetDialogTitle;

  /// No description provided for @resetDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone. You\'ll go through onboarding again.'**
  String get resetDialogBody;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @languageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSwedish.
  ///
  /// In en, this message translates to:
  /// **'Svenska'**
  String get languageSwedish;

  /// No description provided for @todaysWorkout.
  ///
  /// In en, this message translates to:
  /// **'Today\'s workout'**
  String get todaysWorkout;

  /// No description provided for @todaysWorkoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Just a few moves. Keep it easy.'**
  String get todaysWorkoutSubtitle;

  /// No description provided for @noWorkoutYet.
  ///
  /// In en, this message translates to:
  /// **'No workout yet.'**
  String get noWorkoutYet;

  /// No description provided for @logExercisePrompt.
  ///
  /// In en, this message translates to:
  /// **'Log every exercise to finish today\'s workout.'**
  String get logExercisePrompt;

  /// No description provided for @completeWorkout.
  ///
  /// In en, this message translates to:
  /// **'Complete workout'**
  String get completeWorkout;

  /// No description provided for @youAreDoneForToday.
  ///
  /// In en, this message translates to:
  /// **'You\'re done for today'**
  String get youAreDoneForToday;

  /// No description provided for @niceworkStreak.
  ///
  /// In en, this message translates to:
  /// **'Nice work — {streak}-day streak.'**
  String niceworkStreak(int streak);

  /// No description provided for @nicework.
  ///
  /// In en, this message translates to:
  /// **'Nice work.'**
  String get nicework;

  /// No description provided for @restUpNewWorkoutTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Rest up — a new workout waits tomorrow.'**
  String get restUpNewWorkoutTomorrow;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String dayStreak(int count);

  /// No description provided for @streakFreezesReady.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 streak freeze ready} other{{count} streak freezes ready}}'**
  String streakFreezesReady(int count);

  /// No description provided for @showUpTomorrowToKeepAlive.
  ///
  /// In en, this message translates to:
  /// **'Show up tomorrow to keep it alive'**
  String get showUpTomorrowToKeepAlive;

  /// No description provided for @showUpTodayToKeepAlive.
  ///
  /// In en, this message translates to:
  /// **'Show up today to keep it alive'**
  String get showUpTodayToKeepAlive;

  /// No description provided for @workoutCompleted.
  ///
  /// In en, this message translates to:
  /// **'Workout completed'**
  String get workoutCompleted;

  /// No description provided for @workoutCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Nice work. You\'re on a {streak}-day streak. See you tomorrow.'**
  String workoutCompletedMessage(int streak);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @coach.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get coach;

  /// No description provided for @coachUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Coach is unavailable right now.'**
  String get coachUnavailable;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @didAndTarget.
  ///
  /// In en, this message translates to:
  /// **'Did {completed} · target {target}'**
  String didAndTarget(String completed, String target);

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target {target}'**
  String target(String target);

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @log.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get log;

  /// No description provided for @targetEnterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Target: {target}. Enter what you actually completed.'**
  String targetEnterCompleted(String target);

  /// No description provided for @secondsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Seconds completed'**
  String get secondsCompleted;

  /// No description provided for @repsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Reps completed'**
  String get repsCompleted;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number (0 or more).'**
  String get enterValidNumber;

  /// No description provided for @maxForExercise.
  ///
  /// In en, this message translates to:
  /// **'Max is {max} for this exercise.'**
  String maxForExercise(int max);

  /// No description provided for @hitTarget.
  ///
  /// In en, this message translates to:
  /// **'Hit target'**
  String get hitTarget;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @whoIsTraining.
  ///
  /// In en, this message translates to:
  /// **'Who\'s training?'**
  String get whoIsTraining;

  /// No description provided for @pickAvatarPrompt.
  ///
  /// In en, this message translates to:
  /// **'Pick an avatar and tell us what to call you.'**
  String get pickAvatarPrompt;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Alex'**
  String get nameHint;

  /// No description provided for @chooseYourAvatar.
  ///
  /// In en, this message translates to:
  /// **'Choose your avatar'**
  String get chooseYourAvatar;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @stepOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOfTotal(int current, int total);

  /// No description provided for @aFewBasics.
  ///
  /// In en, this message translates to:
  /// **'A few basics'**
  String get aFewBasics;

  /// No description provided for @aFewBasicsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Helps us scale workouts gently to you.'**
  String get aFewBasicsSubtitle;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'{value} cm'**
  String heightCm(int value);

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'{value} kg'**
  String weightKg(int value);

  /// No description provided for @howActiveAreYou.
  ///
  /// In en, this message translates to:
  /// **'How active are you?'**
  String get howActiveAreYou;

  /// No description provided for @howActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll start easier than you think — on purpose.'**
  String get howActiveSubtitle;

  /// No description provided for @activityLevelBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get activityLevelBeginner;

  /// No description provided for @activityLevelBeginnerDesc.
  ///
  /// In en, this message translates to:
  /// **'Just getting started'**
  String get activityLevelBeginnerDesc;

  /// No description provided for @activityLevelSometimes.
  ///
  /// In en, this message translates to:
  /// **'Sometimes active'**
  String get activityLevelSometimes;

  /// No description provided for @activityLevelSometimesDesc.
  ///
  /// In en, this message translates to:
  /// **'A few times a month'**
  String get activityLevelSometimesDesc;

  /// No description provided for @activityLevelRegular.
  ///
  /// In en, this message translates to:
  /// **'Regularly active'**
  String get activityLevelRegular;

  /// No description provided for @activityLevelRegularDesc.
  ///
  /// In en, this message translates to:
  /// **'Several times a week'**
  String get activityLevelRegularDesc;

  /// No description provided for @anythingToAvoid.
  ///
  /// In en, this message translates to:
  /// **'Anything to avoid?'**
  String get anythingToAvoid;

  /// No description provided for @anythingToAvoidSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional. We\'ll skip exercises that stress these areas.'**
  String get anythingToAvoidSubtitle;

  /// No description provided for @injuryKnees.
  ///
  /// In en, this message translates to:
  /// **'Knees'**
  String get injuryKnees;

  /// No description provided for @injuryBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get injuryBack;

  /// No description provided for @injuryShoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get injuryShoulders;

  /// No description provided for @injuryNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get injuryNone;

  /// No description provided for @injuryNoneDesc.
  ///
  /// In en, this message translates to:
  /// **'No limitations'**
  String get injuryNoneDesc;

  /// No description provided for @injuryAdaptWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Adapt workouts around this'**
  String get injuryAdaptWorkouts;

  /// No description provided for @fitnessCheck.
  ///
  /// In en, this message translates to:
  /// **'Fitness check'**
  String get fitnessCheck;

  /// No description provided for @fitnessCheckSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Instead of guessing what you can do — measure it. Take your time. Good form beats max effort.'**
  String get fitnessCheckSubtitle;

  /// No description provided for @exerciseOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Exercise {current} of {total}'**
  String exerciseOfTotal(int current, int total);

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get seconds;

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// No description provided for @secondsHint.
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get secondsHint;

  /// No description provided for @repsHint.
  ///
  /// In en, this message translates to:
  /// **'reps'**
  String get repsHint;

  /// No description provided for @enterValidNumberSimple.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enterValidNumberSimple;

  /// No description provided for @maxForExerciseSimple.
  ///
  /// In en, this message translates to:
  /// **'Max is {max} for this exercise'**
  String maxForExerciseSimple(int max);

  /// No description provided for @saveAndStart.
  ///
  /// In en, this message translates to:
  /// **'Save & start'**
  String get saveAndStart;

  /// No description provided for @nextExercise.
  ///
  /// In en, this message translates to:
  /// **'Next exercise'**
  String get nextExercise;

  /// No description provided for @couldNotSaveAssessment.
  ///
  /// In en, this message translates to:
  /// **'Could not save assessment. Please try again.'**
  String get couldNotSaveAssessment;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @progressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Small gains, clearly visible.'**
  String get progressSubtitle;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @best.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get best;

  /// No description provided for @workouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workouts;

  /// No description provided for @recentWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Recent workouts'**
  String get recentWorkouts;

  /// No description provided for @completeWorkoutToSeeHistory.
  ///
  /// In en, this message translates to:
  /// **'Complete a workout to see your history here.'**
  String get completeWorkoutToSeeHistory;

  /// No description provided for @exercisesLogged.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises logged'**
  String exercisesLogged(int count);

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @exerciseTargets.
  ///
  /// In en, this message translates to:
  /// **'Exercise targets'**
  String get exerciseTargets;

  /// No description provided for @completeAssessmentToStart.
  ///
  /// In en, this message translates to:
  /// **'Complete your assessment to start tracking.'**
  String get completeAssessmentToStart;

  /// No description provided for @targetValue.
  ///
  /// In en, this message translates to:
  /// **'Target {value}'**
  String targetValue(String value);

  /// No description provided for @prValue.
  ///
  /// In en, this message translates to:
  /// **'PR {value}'**
  String prValue(String value);

  /// No description provided for @recentPerformanceChart.
  ///
  /// In en, this message translates to:
  /// **'Recent performance chart for {name}'**
  String recentPerformanceChart(String name);

  /// No description provided for @achievementFirstStepTitle.
  ///
  /// In en, this message translates to:
  /// **'First step'**
  String get achievementFirstStepTitle;

  /// No description provided for @achievementFirstStepDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete your first workout'**
  String get achievementFirstStepDesc;

  /// No description provided for @achievementThreeInRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Three in a row'**
  String get achievementThreeInRowTitle;

  /// No description provided for @achievementThreeInRowDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach a 3-day streak'**
  String get achievementThreeInRowDesc;

  /// No description provided for @achievementWeekOfMomentumTitle.
  ///
  /// In en, this message translates to:
  /// **'Week of momentum'**
  String get achievementWeekOfMomentumTitle;

  /// No description provided for @achievementWeekOfMomentumDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach a 7-day streak'**
  String get achievementWeekOfMomentumDesc;

  /// No description provided for @achievementTenSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ten sessions'**
  String get achievementTenSessionsTitle;

  /// No description provided for @achievementTenSessionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 10 workouts'**
  String get achievementTenSessionsDesc;

  /// No description provided for @achievementSafetyNetTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety net'**
  String get achievementSafetyNetTitle;

  /// No description provided for @achievementSafetyNetDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn a streak freeze'**
  String get achievementSafetyNetDesc;

  /// No description provided for @exercisePushUps.
  ///
  /// In en, this message translates to:
  /// **'Push-ups'**
  String get exercisePushUps;

  /// No description provided for @exercisePushUpsCue.
  ///
  /// In en, this message translates to:
  /// **'Chest to the floor with control.'**
  String get exercisePushUpsCue;

  /// No description provided for @exercisePushUpsHowTo.
  ///
  /// In en, this message translates to:
  /// **'Start in a high plank with hands under your shoulders. Lower your chest toward the floor, keeping elbows close to your body, then press back up. Keep your body in a straight line from head to heels.'**
  String get exercisePushUpsHowTo;

  /// No description provided for @exerciseKneePushUps.
  ///
  /// In en, this message translates to:
  /// **'Knee push-ups'**
  String get exerciseKneePushUps;

  /// No description provided for @exerciseKneePushUpsCue.
  ///
  /// In en, this message translates to:
  /// **'Same as push-ups, from the knees.'**
  String get exerciseKneePushUpsCue;

  /// No description provided for @exerciseKneePushUpsHowTo.
  ///
  /// In en, this message translates to:
  /// **'Kneel on the floor and place your hands under your shoulders. Keep a straight line from knees to head. Lower your chest toward the floor, then press back up with control.'**
  String get exerciseKneePushUpsHowTo;

  /// No description provided for @exerciseChairDips.
  ///
  /// In en, this message translates to:
  /// **'Chair dips'**
  String get exerciseChairDips;

  /// No description provided for @exerciseChairDipsCue.
  ///
  /// In en, this message translates to:
  /// **'Lower until elbows are near 90°.'**
  String get exerciseChairDipsCue;

  /// No description provided for @exerciseChairDipsHowTo.
  ///
  /// In en, this message translates to:
  /// **'Sit on the edge of a sturdy chair, hands beside your hips. Slide forward so your hips clear the seat. Bend your elbows to lower your body, then press up. Keep shoulders down and away from your ears.'**
  String get exerciseChairDipsHowTo;

  /// No description provided for @exerciseSquats.
  ///
  /// In en, this message translates to:
  /// **'Squats'**
  String get exerciseSquats;

  /// No description provided for @exerciseSquatsCue.
  ///
  /// In en, this message translates to:
  /// **'Sit back, chest up, heels down.'**
  String get exerciseSquatsCue;

  /// No description provided for @exerciseSquatsHowTo.
  ///
  /// In en, this message translates to:
  /// **'Stand with feet about shoulder-width apart. Sit your hips back as if into a chair, keep your chest lifted, and lower until thighs are roughly parallel to the floor (or as deep as comfortable). Drive through your heels to stand.'**
  String get exerciseSquatsHowTo;

  /// No description provided for @exerciseLunges.
  ///
  /// In en, this message translates to:
  /// **'Lunges'**
  String get exerciseLunges;

  /// No description provided for @exerciseLungesCue.
  ///
  /// In en, this message translates to:
  /// **'Alternate legs. Count every step.'**
  String get exerciseLungesCue;

  /// No description provided for @exerciseLungesHowTo.
  ///
  /// In en, this message translates to:
  /// **'Step one foot forward and bend both knees until the back knee nearly touches the floor. Keep your front knee above your ankle. Push back to standing and switch legs. Count total reps across both sides.'**
  String get exerciseLungesHowTo;

  /// No description provided for @exerciseGluteBridge.
  ///
  /// In en, this message translates to:
  /// **'Glute bridge'**
  String get exerciseGluteBridge;

  /// No description provided for @exerciseGluteBridgeCue.
  ///
  /// In en, this message translates to:
  /// **'Squeeze at the top, then lower.'**
  String get exerciseGluteBridgeCue;

  /// No description provided for @exerciseGluteBridgeHowTo.
  ///
  /// In en, this message translates to:
  /// **'Lie on your back with knees bent and feet flat on the floor. Press through your heels to lift your hips until your body forms a straight line from shoulders to knees. Squeeze your glutes at the top, then lower slowly.'**
  String get exerciseGluteBridgeHowTo;

  /// No description provided for @exerciseCalfRaises.
  ///
  /// In en, this message translates to:
  /// **'Calf raises'**
  String get exerciseCalfRaises;

  /// No description provided for @exerciseCalfRaisesCue.
  ///
  /// In en, this message translates to:
  /// **'Rise onto your toes, pause, lower.'**
  String get exerciseCalfRaisesCue;

  /// No description provided for @exerciseCalfRaisesHowTo.
  ///
  /// In en, this message translates to:
  /// **'Stand tall with feet hip-width apart. Rise onto the balls of your feet as high as you can, pause briefly, then lower with control. Hold a wall or chair for balance if needed.'**
  String get exerciseCalfRaisesHowTo;

  /// No description provided for @exercisePlank.
  ///
  /// In en, this message translates to:
  /// **'Plank'**
  String get exercisePlank;

  /// No description provided for @exercisePlankCue.
  ///
  /// In en, this message translates to:
  /// **'Hold a straight line — no sagging.'**
  String get exercisePlankCue;

  /// No description provided for @exercisePlankHowTo.
  ///
  /// In en, this message translates to:
  /// **'Place forearms on the floor with elbows under shoulders, or hold a high plank on your hands. Keep your body straight from head to heels. Brace your core, squeeze your glutes, and breathe steadily. Stop if your form breaks.'**
  String get exercisePlankHowTo;

  /// No description provided for @exerciseSidePlank.
  ///
  /// In en, this message translates to:
  /// **'Side plank'**
  String get exerciseSidePlank;

  /// No description provided for @exerciseSidePlankCue.
  ///
  /// In en, this message translates to:
  /// **'Log the weaker side\'s time.'**
  String get exerciseSidePlankCue;

  /// No description provided for @exerciseSidePlankHowTo.
  ///
  /// In en, this message translates to:
  /// **'Lie on one side with your elbow under your shoulder. Lift your hips so your body forms a straight line. Hold, then switch sides. Log the time of your weaker side.'**
  String get exerciseSidePlankHowTo;

  /// No description provided for @exerciseDeadBug.
  ///
  /// In en, this message translates to:
  /// **'Dead bug'**
  String get exerciseDeadBug;

  /// No description provided for @exerciseDeadBugCue.
  ///
  /// In en, this message translates to:
  /// **'Slow moves, back pressed down.'**
  String get exerciseDeadBugCue;

  /// No description provided for @exerciseDeadBugHowTo.
  ///
  /// In en, this message translates to:
  /// **'Lie on your back with arms toward the ceiling and knees bent at 90°. Slowly extend opposite arm and leg toward the floor without letting your lower back arch. Return and switch sides. One rep = both sides once.'**
  String get exerciseDeadBugHowTo;

  /// No description provided for @exerciseBirdDog.
  ///
  /// In en, this message translates to:
  /// **'Bird dog'**
  String get exerciseBirdDog;

  /// No description provided for @exerciseBirdDogCue.
  ///
  /// In en, this message translates to:
  /// **'Opposite arm and leg, then switch.'**
  String get exerciseBirdDogCue;

  /// No description provided for @exerciseBirdDogHowTo.
  ///
  /// In en, this message translates to:
  /// **'Start on all fours with hands under shoulders and knees under hips. Extend one arm forward and the opposite leg back, keeping hips level. Pause, return, then switch. One rep = both sides once.'**
  String get exerciseBirdDogHowTo;

  /// No description provided for @exerciseJumpingJacks.
  ///
  /// In en, this message translates to:
  /// **'Jumping jacks'**
  String get exerciseJumpingJacks;

  /// No description provided for @exerciseJumpingJacksCue.
  ///
  /// In en, this message translates to:
  /// **'Steady rhythm, soft landings.'**
  String get exerciseJumpingJacksCue;

  /// No description provided for @exerciseJumpingJacksHowTo.
  ///
  /// In en, this message translates to:
  /// **'Stand with feet together and arms at your sides. Jump your feet out while raising your arms overhead, then jump back to the start. Land softly and keep a steady pace.'**
  String get exerciseJumpingJacksHowTo;

  /// No description provided for @exerciseHighKnees.
  ///
  /// In en, this message translates to:
  /// **'High knees'**
  String get exerciseHighKnees;

  /// No description provided for @exerciseHighKneesCue.
  ///
  /// In en, this message translates to:
  /// **'Drive knees up, stay light.'**
  String get exerciseHighKneesCue;

  /// No description provided for @exerciseHighKneesHowTo.
  ///
  /// In en, this message translates to:
  /// **'Jog in place while driving your knees up toward hip height. Pump your arms and stay on the balls of your feet. Count each knee drive as one rep.'**
  String get exerciseHighKneesHowTo;

  /// No description provided for @exerciseMountainClimbers.
  ///
  /// In en, this message translates to:
  /// **'Mountain climbers'**
  String get exerciseMountainClimbers;

  /// No description provided for @exerciseMountainClimbersCue.
  ///
  /// In en, this message translates to:
  /// **'Hips level as you switch legs.'**
  String get exerciseMountainClimbersCue;

  /// No description provided for @exerciseMountainClimbersHowTo.
  ///
  /// In en, this message translates to:
  /// **'Start in a high plank. Drive one knee toward your chest, then quickly switch legs as if running in place. Keep hips low and level. Count each knee drive as one rep.'**
  String get exerciseMountainClimbersHowTo;

  /// No description provided for @exerciseUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown exercise'**
  String get exerciseUnknown;

  /// No description provided for @exerciseUnknownCue.
  ///
  /// In en, this message translates to:
  /// **'This exercise is no longer in the catalog.'**
  String get exerciseUnknownCue;

  /// No description provided for @exerciseUnknownHowTo.
  ///
  /// In en, this message translates to:
  /// **'Skip or re-take your assessment to refresh your plan.'**
  String get exerciseUnknownHowTo;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sv'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sv':
      return AppLocalizationsSv();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
