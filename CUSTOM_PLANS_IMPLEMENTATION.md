# Custom Workout Plans Implementation

## Översikt

Detta tillägg gör det möjligt för användare att skapa anpassade träningsplaner från AI-konversationer och aktivera dem så att dagliga pass genereras baserat på planen istället för det automatiska systemet.

## Funktioner

### 1. Generera Träningsplan från Konversation
- AI analyserar konversationen och skapar en strukturerad veckoplan
- Planen inkluderar specifika övningar, repetitioner, set och viloperioder
- JSON-format för att säkerställa strukturerad data
- Stöd för både aktivitetspass och vilodagar

### 2. Plan-hantering
- Visa alla sparade träningsplaner
- Aktivera/inaktivera planer
- Ta bort planer
- Endast en plan kan vara aktiv åt gången

### 3. Integration med Dagliga Pass
- När en plan är aktiv: dagliga pass skapas från planen baserat på veckodag
- När ingen plan är aktiv: dagliga pass genereras automatiskt som tidigare
- Planen följer veckodagar (1=Måndag, 7=Söndag)

## Teknisk Implementation

### Nya Modeller

#### CustomWorkoutPlan
```dart
class CustomWorkoutPlan {
  String id;
  String name;
  String? description;
  List<DayWorkout> weeklySchedule;
  DateTime createdAt;
  String? conversationId;
  bool isActive;
}
```

#### DayWorkout
```dart
class DayWorkout {
  int dayOfWeek;  // 1-7 (Måndag-Söndag)
  List<PlannedExercise> exercises;
  bool isRestDay;
  String? notes;
}
```

#### PlannedExercise
```dart
class PlannedExercise {
  String exerciseId;
  int targetReps;  // eller sekunder för plank
  int sets;
  int? restSeconds;
  String? notes;
}
```

### Databas-schema (v4)

```sql
CREATE TABLE custom_workout_plans (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  weekly_schedule TEXT NOT NULL,  -- JSON
  created_at TEXT NOT NULL,
  conversation_id TEXT,
  is_active INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (conversation_id) REFERENCES workout_conversations (id) ON DELETE SET NULL
);

CREATE INDEX idx_custom_workout_plans_active ON custom_workout_plans(is_active);
```

### AI Plan-generering

#### PlanGeneratorClient
Använder Groq API för att:
1. Analysera hela konversationshistoriken
2. Inkludera användarprofil (ålder, aktivitetsnivå, skador)
3. Generera strukturerad JSON-plan
4. Validera mot tillgängliga övningar

Tillgängliga övningar:
- `push_ups` - Armhävningar
- `knee_push_ups` - Knäarmhävningar
- `chair_dips` - Stoldips
- `squats` - Knäböj
- `lunges` - Utfall
- `glute_bridge` - Höftlyft
- `calf_raises` - Tåhävningar
- `plank` - Plankan (sekunder)
- `side_plank` - Sidplankan (sekunder)
- `dead_bug` - Dödskalbaggen
- `bird_dog` - Fågelhund
- `jumping_jacks` - Hopptomtar
- `high_knees` - Höga knän
- `mountain_climbers` - Bergsklättrare

### Repository-ändringar

`MomentumRepository.ensureTodaysWorkout()` modifierad för att:
1. Först kolla om det finns en aktiv custom plan
2. Om aktiv plan finns: använd den för att generera dagens pass
3. Om ingen aktiv plan: använd automatisk generering som tidigare

```dart
Future<DailyWorkout> ensureTodaysWorkout({
  required UserProfile profile,
}) async {
  // ... check existing workout ...
  
  final activePlan = await db.getActivePlan();
  
  if (activePlan != null) {
    workout = _buildWorkoutFromCustomPlan(
      id: _uuid.v4(),
      date: today,
      plan: activePlan,
    );
  } else {
    // Auto-generate as before
  }
  
  // ...
}
```

## Användarflöde

### Skapa och Aktivera en Plan

1. **Diskutera med AI**
   - Öppna Träningsplanerare från Settings → Verktyg
   - Ha en konversation om träningsbehov och mål
   - Minst 4 meddelanden rekommenderas för bästa resultat

2. **Generera Plan**
   - Klicka på "Skapa träningsplan"-ikonen i app bar
   - AI analyserar konversationen och skapar en strukturerad plan
   - Granska planen (namn, beskrivning, veckoschema)
   - Välj att aktivera direkt eller spara utan aktivering

3. **Hantera Planer**
   - Öppna "Mina träningsplaner" från Settings → Verktyg
   - Se alla sparade planer
   - Aktivera/inaktivera planer med en knapp
   - Ta bort planer som inte längre behövs

4. **Använda Aktiv Plan**
   - När en plan är aktiv: dagens pass följer planens veckoschema
   - Systemet matchar automatiskt dagens veckodag med planen
   - På vilodagar: inga övningar i dagens pass
   - Streak och progress fungerar som vanligt

### Inaktivera Plan

- Gå till "Mina träningsplaner"
- Klicka "Inaktivera" på den aktiva planen
- Systemet återgår till automatisk pass-generering

## Nya Filer

### Data Layer
- `lib/data/ai/plan_generator_client.dart` - AI-klient för plan-generering
- `lib/domain/models/custom_workout_plan.dart` - Plan-modeller

### UI
- `lib/features/settings/workout_plans_screen.dart` - Plan-hantering

### State Management
- `lib/providers/custom_plans_provider.dart` - Riverpod för plans

### Dokumentation
- `CUSTOM_PLANS_IMPLEMENTATION.md` - Denna fil

## Modifierade Filer

- `lib/data/local/app_database.dart` - Database v4 med custom_workout_plans
- `lib/data/repositories/momentum_repository.dart` - Integration med custom plans
- `lib/features/workout_planner/workout_planner_screen.dart` - UI för plan-generering
- `lib/providers/workout_planner_provider.dart` - Plan-generering i provider
- `lib/routing/app_router.dart` - Ny route för plan-hantering
- `lib/features/settings/settings_screen.dart` - Länk till plan-hantering
- `lib/l10n/app_sv.arb` - Svenska översättningar
- `lib/l10n/app_en.arb` - Engelska översättningar

## Exempel på AI-genererad Plan

```json
{
  "name": "Military Calisthenics för 47-åring",
  "description": "15 minuter varje morgon, fokus på hållbarhet",
  "weeklySchedule": [
    {
      "dayOfWeek": 1,
      "isRestDay": false,
      "exercises": [
        {
          "exerciseId": "push_ups",
          "targetReps": 10,
          "sets": 3,
          "restSeconds": 60,
          "notes": "Fokusera på formen"
        },
        {
          "exerciseId": "squats",
          "targetReps": 15,
          "sets": 3,
          "restSeconds": 45
        },
        {
          "exerciseId": "plank",
          "targetReps": 30,
          "sets": 1,
          "notes": "30 sekunder"
        }
      ],
      "notes": "Fullt pass"
    },
    {
      "dayOfWeek": 2,
      "isRestDay": false,
      "exercises": [
        {
          "exerciseId": "lunges",
          "targetReps": 10,
          "sets": 2,
          "restSeconds": 45
        },
        {
          "exerciseId": "plank",
          "targetReps": 30,
          "sets": 1
        }
      ],
      "notes": "Lätt rörlighetspass"
    },
    {
      "dayOfWeek": 4,
      "isRestDay": true,
      "exercises": [],
      "notes": "Vilodag"
    }
  ]
}
```

## Testning

### Manual Testplan

1. **Skapa Plan från Konversation**
   - [ ] Ha en konversation om träning
   - [ ] Klicka på "Skapa träningsplan"
   - [ ] Verifiera att plan genereras korrekt
   - [ ] Granska planen i dialog
   - [ ] Aktivera planen

2. **Dagliga Pass med Aktiv Plan**
   - [ ] Verifiera att dagens pass följer planen
   - [ ] Kontrollera att rätt övningar visas
   - [ ] Testa på olika veckodagar
   - [ ] Verifiera att vilodagar fungerar

3. **Plan-hantering**
   - [ ] Öppna "Mina träningsplaner"
   - [ ] Se alla sparade planer
   - [ ] Inaktivera aktiv plan
   - [ ] Aktivera annan plan
   - [ ] Ta bort en plan

4. **Återgång till Auto-generering**
   - [ ] Inaktivera alla planer
   - [ ] Verifiera att auto-generering fungerar igen
   - [ ] Kontrollera att adaptiv svårighet fungerar

## Begränsningar

- Endast övningar från den fördefinierade listan kan användas
- En plan per vecka (7 dagar)
- Endast en aktiv plan åt gången
- AI:n kräver internetanslutning och AI-consent

## Framtida Förbättringar

- [ ] Möjlighet att manuellt redigera genererade planer
- [ ] Stöd för multiple-week progression plans
- [ ] Import/export av planer
- [ ] Dela planer med andra användare
- [ ] Plan-templates för vanliga träningstyper
- [ ] Progressionslogg specifik för custom plans
- [ ] Notifikationer om planändringar
- [ ] Custom övningar utöver de fördefinierade
- [ ] Planhistorik och versionshantering

## Databas-migration

Automatisk migration från v3 till v4:
- Skapar `custom_workout_plans` tabell
- Skapar index för snabb filtrering på aktiva planer
- Bakåtkompatibel - ingen data förloras
- Foreign key till conversations med ON DELETE SET NULL

## Säkerhet och Validering

- AI-genererad JSON parsas och valideras
- Endast kända exerciseId accepteras
- Veckodag valideras (1-7)
- Target reps/sekunder begränsas av InputLimits
- Sets begränsas till rimliga värden (1-10)
