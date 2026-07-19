// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appName => 'MomentumFit';

  @override
  String get appTagline => 'Bli lite starkare varje dag.';

  @override
  String get goodMorning => 'God morgon';

  @override
  String get goodAfternoon => 'God eftermiddag';

  @override
  String get goodEvening => 'God kväll';

  @override
  String get settings => 'Inställningar';

  @override
  String get navToday => 'Idag';

  @override
  String get reminders => 'Påminnelser';

  @override
  String get aiCoach => 'AI-Coach';

  @override
  String get training => 'Träning';

  @override
  String get dangerZone => 'Farlig zon';

  @override
  String get language => 'Språk';

  @override
  String get dailyReminder => 'Daglig påminnelse';

  @override
  String get dailyReminderDescription =>
      'Få en påminnelse så du inte missar en dag';

  @override
  String dailyReminderEnabled(String time) {
    return 'Lokal avisering kl $time';
  }

  @override
  String get reminderTime => 'Påminnelsetid';

  @override
  String get personalizedAiNudges => 'Personliga AI-tips';

  @override
  String get aiConsentEnabled =>
      'Träningsstatistik kan skickas till coach-tjänsten. Namn och skador förblir privata.';

  @override
  String get aiConsentDisabled =>
      'Använder lugna offline-tips — inget lämnar din enhet.';

  @override
  String get retakeAssessment => 'Gör om bedömning';

  @override
  String get retakeAssessmentSubtitle => 'Rekommenderas var 4:e vecka';

  @override
  String get retakeAssessmentDialogTitle => 'Gör om bedömning?';

  @override
  String get retakeAssessmentDialogBody =>
      'Dina nuvarande träningsmål kommer att räknas om från en ny konditionstest.';

  @override
  String get cancel => 'Avbryt';

  @override
  String get continueAction => 'Fortsätt';

  @override
  String ageYears(int age) {
    return '$age år';
  }

  @override
  String get defaultFriendName => 'Vän';

  @override
  String get somethingWentWrong => 'Något gick fel. Försök igen.';

  @override
  String get tryAgain => 'Försök igen';

  @override
  String get notificationsPermissionDenied =>
      'Behörighet för aviseringar nekades. Aktivera dem i systeminställningarna.';

  @override
  String get reminderNotificationTitle => 'Din streak väntar';

  @override
  String get reminderNotificationBody =>
      'Dagens pass är redo. Några minuter räcker.';

  @override
  String get reminderChannelName => 'Dagliga påminnelser';

  @override
  String get reminderChannelDescription =>
      'Dagliga MomentumFit-påminnelser om träning';

  @override
  String get resetAllData => 'Återställ all data';

  @override
  String get resetAllDataSubtitle => 'Rensar profil, streaks och historik';

  @override
  String get resetDialogTitle => 'Återställa allt?';

  @override
  String get resetDialogBody =>
      'Detta kan inte ångras. Du kommer att gå igenom introduktionen igen.';

  @override
  String get reset => 'Återställ';

  @override
  String get languageSystemDefault => 'Systemstandard';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSwedish => 'Svenska';

  @override
  String get todaysWorkout => 'Dagens pass';

  @override
  String get todaysWorkoutSubtitle => 'Bara några övningar. Håll det enkelt.';

  @override
  String get noWorkoutYet => 'Inget pass ännu.';

  @override
  String get logExercisePrompt =>
      'Logga varje övning för att slutföra dagens pass.';

  @override
  String get completeWorkout => 'Slutför passet';

  @override
  String get youAreDoneForToday => 'Du är klar för idag';

  @override
  String niceworkStreak(int streak) {
    return 'Bra jobbat — $streak dagars streak.';
  }

  @override
  String get nicework => 'Bra jobbat.';

  @override
  String get restUpNewWorkoutTomorrow =>
      'Vila upp dig — ett nytt pass väntar imorgon.';

  @override
  String dayStreak(int count) {
    return '$count dagars streak';
  }

  @override
  String streakFreezesReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count streak freezes redo',
      one: '1 streak freeze redo',
    );
    return '$_temp0';
  }

  @override
  String get showUpTomorrowToKeepAlive =>
      'Dyk upp imorgon för att hålla den vid liv';

  @override
  String get showUpTodayToKeepAlive => 'Dyk upp idag för att hålla den vid liv';

  @override
  String get workoutCompleted => 'Passet slutfört';

  @override
  String workoutCompletedMessage(int streak) {
    return 'Bra jobbat. Du har en $streak-dagars streak. Vi ses imorgon.';
  }

  @override
  String get done => 'Klart';

  @override
  String get coach => 'Coach';

  @override
  String get coachUnavailable => 'Coach är inte tillgänglig just nu.';

  @override
  String get retry => 'Försök igen';

  @override
  String didAndTarget(String completed, String target) {
    return 'Gjorde $completed · mål $target';
  }

  @override
  String target(String target) {
    return 'Mål $target';
  }

  @override
  String get edit => 'Redigera';

  @override
  String get log => 'Logga';

  @override
  String targetEnterCompleted(String target) {
    return 'Mål: $target. Ange vad du faktiskt slutförde.';
  }

  @override
  String get secondsCompleted => 'Sekunder slutförda';

  @override
  String get repsCompleted => 'Reps slutförda';

  @override
  String get enterValidNumber => 'Ange ett giltigt nummer (0 eller mer).';

  @override
  String maxForExercise(int max) {
    return 'Max är $max för denna övning.';
  }

  @override
  String get hitTarget => 'Nådde målet';

  @override
  String get save => 'Spara';

  @override
  String get whoIsTraining => 'Vem tränar?';

  @override
  String get pickAvatarPrompt =>
      'Välj en avatar och berätta vad vi ska kalla dig.';

  @override
  String get yourName => 'Ditt namn';

  @override
  String get nameHint => 'Alex';

  @override
  String get chooseYourAvatar => 'Välj din avatar';

  @override
  String get back => 'Tillbaka';

  @override
  String get next => 'Nästa';

  @override
  String stepOfTotal(int current, int total) {
    return 'Steg $current av $total';
  }

  @override
  String get aFewBasics => 'Några grundläggande uppgifter';

  @override
  String get aFewBasicsSubtitle =>
      'Hjälper oss att anpassa passen försiktigt efter dig.';

  @override
  String get age => 'Ålder';

  @override
  String get height => 'Längd';

  @override
  String get weight => 'Vikt';

  @override
  String heightCm(int value) {
    return '$value cm';
  }

  @override
  String weightKg(int value) {
    return '$value kg';
  }

  @override
  String get howActiveAreYou => 'Hur aktiv är du?';

  @override
  String get howActiveSubtitle => 'Vi börjar enklare än du tror — med avsikt.';

  @override
  String get activityLevelBeginner => 'Nybörjare';

  @override
  String get activityLevelBeginnerDesc => 'Precis börjat';

  @override
  String get activityLevelSometimes => 'Ibland aktiv';

  @override
  String get activityLevelSometimesDesc => 'Några gånger i månaden';

  @override
  String get activityLevelRegular => 'Regelbundet aktiv';

  @override
  String get activityLevelRegularDesc => 'Flera gånger i veckan';

  @override
  String get anythingToAvoid => 'Något att undvika?';

  @override
  String get anythingToAvoidSubtitle =>
      'Valfritt. Vi hoppar över övningar som belastar dessa områden.';

  @override
  String get injuryKnees => 'Knän';

  @override
  String get injuryBack => 'Rygg';

  @override
  String get injuryShoulders => 'Axlar';

  @override
  String get injuryNone => 'Inget';

  @override
  String get injuryNoneDesc => 'Inga begränsningar';

  @override
  String get injuryAdaptWorkouts => 'Anpassa pass kring detta';

  @override
  String get fitnessCheck => 'Konditionstest';

  @override
  String get fitnessCheckSubtitle =>
      'I stället för att gissa vad du kan — mät det. Ta din tid. Bra form slår maxinsats.';

  @override
  String exerciseOfTotal(int current, int total) {
    return 'Övning $current av $total';
  }

  @override
  String get seconds => 'Sekunder';

  @override
  String get reps => 'Reps';

  @override
  String get secondsHint => 'sek';

  @override
  String get repsHint => 'reps';

  @override
  String get enterValidNumberSimple => 'Ange ett giltigt nummer';

  @override
  String maxForExerciseSimple(int max) {
    return 'Max är $max för denna övning';
  }

  @override
  String get saveAndStart => 'Spara och starta';

  @override
  String get nextExercise => 'Nästa övning';

  @override
  String get couldNotSaveAssessment =>
      'Kunde inte spara bedömning. Försök igen.';

  @override
  String get progress => 'Framsteg';

  @override
  String get progressSubtitle => 'Små vinster, tydligt synliga.';

  @override
  String get streak => 'Streak';

  @override
  String get best => 'Bäst';

  @override
  String get workouts => 'Pass';

  @override
  String get recentWorkouts => 'Senaste passen';

  @override
  String get completeWorkoutToSeeHistory =>
      'Slutför ett pass för att se din historik här.';

  @override
  String exercisesLogged(int count) {
    return '$count övningar loggade';
  }

  @override
  String get achievements => 'Prestationer';

  @override
  String get exerciseTargets => 'Träningsmål';

  @override
  String get completeAssessmentToStart =>
      'Slutför din bedömning för att börja spåra.';

  @override
  String targetValue(String value) {
    return 'Mål $value';
  }

  @override
  String prValue(String value) {
    return 'PR $value';
  }

  @override
  String recentPerformanceChart(String name) {
    return 'Senaste prestationsdiagram för $name';
  }

  @override
  String get achievementFirstStepTitle => 'Första steget';

  @override
  String get achievementFirstStepDesc => 'Slutför ditt första pass';

  @override
  String get achievementThreeInRowTitle => 'Tre i rad';

  @override
  String get achievementThreeInRowDesc => 'Nå en 3-dagars streak';

  @override
  String get achievementWeekOfMomentumTitle => 'Vecka av momentum';

  @override
  String get achievementWeekOfMomentumDesc => 'Nå en 7-dagars streak';

  @override
  String get achievementTenSessionsTitle => 'Tio sessioner';

  @override
  String get achievementTenSessionsDesc => 'Slutför 10 pass';

  @override
  String get achievementSafetyNetTitle => 'Säkerhetsnät';

  @override
  String get achievementSafetyNetDesc => 'Tjäna en streak freeze';

  @override
  String get exercisePushUps => 'Armhävningar';

  @override
  String get exercisePushUpsCue => 'Bröstet mot golvet med kontroll.';

  @override
  String get exercisePushUpsHowTo =>
      'Börja i en hög plank med händerna under axlarna. Sänk bröstet mot golvet och håll armbågarna nära kroppen, tryck sedan tillbaka upp. Håll kroppen i en rak linje från huvud till hälar.';

  @override
  String get exerciseKneePushUps => 'Knäarmhävningar';

  @override
  String get exerciseKneePushUpsCue => 'Samma som armhävningar, från knäna.';

  @override
  String get exerciseKneePushUpsHowTo =>
      'Knäböj på golvet och placera händerna under axlarna. Håll en rak linje från knän till huvud. Sänk bröstet mot golvet och tryck sedan tillbaka upp med kontroll.';

  @override
  String get exerciseChairDips => 'Stoldips';

  @override
  String get exerciseChairDipsCue => 'Sänk tills armbågarna är nära 90°.';

  @override
  String get exerciseChairDipsHowTo =>
      'Sitt på kanten av en stabil stol, händerna vid höfterna. Glid framåt så höfterna är utanför sitsen. Böj armbågarna för att sänka kroppen, tryck sedan upp. Håll axlarna nere och borta från öronen.';

  @override
  String get exerciseSquats => 'Knäböj';

  @override
  String get exerciseSquatsCue => 'Sitt bakåt, bröst upp, hälar ner.';

  @override
  String get exerciseSquatsHowTo =>
      'Stå med fötterna ungefär axelbrett isär. Sitt bakåt med höfterna som om du ska sätta dig i en stol, håll bröstet uppåt och sänk dig tills låren är ungefär parallella med golvet (eller så djupt som är bekvämt). Tryck genom hälarna för att ställa dig upp.';

  @override
  String get exerciseLunges => 'Utfall';

  @override
  String get exerciseLungesCue => 'Alternera ben. Räkna varje steg.';

  @override
  String get exerciseLungesHowTo =>
      'Ta ett steg framåt med en fot och böj båda knäna tills det bakre knäet nästan rör golvet. Håll det främre knäet över ankeln. Tryck tillbaka till stående och byt ben. Räkna totala reps över båda sidorna.';

  @override
  String get exerciseGluteBridge => 'Höftlyft';

  @override
  String get exerciseGluteBridgeCue => 'Spänn högst upp, sänk sedan.';

  @override
  String get exerciseGluteBridgeHowTo =>
      'Ligg på rygg med knäna böjda och fötterna platta på golvet. Tryck genom hälarna för att lyfta höfterna tills kroppen bildar en rak linje från axlar till knän. Spänn gluteusmusklerna högst upp och sänk sedan långsamt.';

  @override
  String get exerciseCalfRaises => 'Tåhävningar';

  @override
  String get exerciseCalfRaisesCue => 'Res dig på tårna, pausa, sänk.';

  @override
  String get exerciseCalfRaisesHowTo =>
      'Stå upprätt med fötterna höftbrett isär. Res dig på tåspetsarna så högt du kan, pausa kort och sänk sedan med kontroll. Håll i en vägg eller stol för balans om det behövs.';

  @override
  String get exercisePlank => 'Plankan';

  @override
  String get exercisePlankCue => 'Håll en rak linje — ingen hängmage.';

  @override
  String get exercisePlankHowTo =>
      'Placera underarmarna på golvet med armbågarna under axlarna, eller håll en hög plank på händerna. Håll kroppen rak från huvud till hälar. Spänn magen, krama ihop gluteus och andas jämnt. Sluta om formen går sönder.';

  @override
  String get exerciseSidePlank => 'Sidplankan';

  @override
  String get exerciseSidePlankCue => 'Logga den svagare sidans tid.';

  @override
  String get exerciseSidePlankHowTo =>
      'Ligg på ena sidan med armbågen under axeln. Lyft höfterna så kroppen bildar en rak linje. Håll, byt sedan sida. Logga tiden för din svagare sida.';

  @override
  String get exerciseDeadBug => 'Dödskalbaggen';

  @override
  String get exerciseDeadBugCue => 'Långsamma rörelser, rygg nertryckt.';

  @override
  String get exerciseDeadBugHowTo =>
      'Ligg på rygg med armarna mot taket och knäna böjda 90°. Sträck långsamt ut motsatt arm och ben mot golvet utan att låta ländryggen välva. Återvänd och byt sida. En rep = båda sidorna en gång.';

  @override
  String get exerciseBirdDog => 'Fågelhund';

  @override
  String get exerciseBirdDogCue => 'Motsatt arm och ben, byt sedan.';

  @override
  String get exerciseBirdDogHowTo =>
      'Börja på alla fyra med händerna under axlarna och knäna under höfterna. Sträck ut en arm framåt och motsatt ben bakåt, håll höfterna i nivå. Pausa, återvänd, byt sedan. En rep = båda sidorna en gång.';

  @override
  String get exerciseJumpingJacks => 'Hopptomtar';

  @override
  String get exerciseJumpingJacksCue => 'Jämn rytm, mjuka landningar.';

  @override
  String get exerciseJumpingJacksHowTo =>
      'Stå med fötterna ihop och armarna vid sidorna. Hoppa ut med fötterna samtidigt som du lyfter armarna över huvudet, hoppa sedan tillbaka till start. Landa mjukt och håll en jämn takt.';

  @override
  String get exerciseHighKnees => 'Höga knän';

  @override
  String get exerciseHighKneesCue => 'Lyft knäna upp, var lätt.';

  @override
  String get exerciseHighKneesHowTo =>
      'Jogga på plats medan du lyfter knäna upp mot höfthöjd. Pumpa armarna och stanna på tåspetsarna. Räkna varje knälyft som en rep.';

  @override
  String get exerciseMountainClimbers => 'Bergsklättrare';

  @override
  String get exerciseMountainClimbersCue => 'Höfter i nivå när du byter ben.';

  @override
  String get exerciseMountainClimbersHowTo =>
      'Börja i en hög plank. Dra ett knä mot bröstet och byt sedan snabbt ben som om du springer på plats. Håll höfterna låga och i nivå. Räkna varje knälyft som en rep.';

  @override
  String get exerciseUnknown => 'Okänd övning';

  @override
  String get exerciseUnknownCue =>
      'Denna övning finns inte längre i katalogen.';

  @override
  String get exerciseUnknownHowTo =>
      'Hoppa över eller gör om din bedömning för att uppdatera din plan.';
}
