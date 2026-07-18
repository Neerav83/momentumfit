# MomentumFit

> Become a little stronger every day.

MomentumFit är inte ännu en träningsapp för maxstyrka.

Målet är att bygga en **daglig vana**. Varje pass ska kännas görbart. Appen anpassar svårigheten så du utmanas — men aldrig överväldigas.

---

## Principer

- Börja löjligt enkelt
- Konsistens slår intensitet
- Små förbättringar varje dag
- Personliga pass
- Streaks som motivation
- Under 5 minuter på hektiska dagar

---

## Funktioner (MVP)

| Del | Vad den gör |
|---|---|
| **Onboarding** | Namn, avatar, ålder/längd/vikt, aktivitetsnivå, skador |
| **Fitness assessment** | Mäter push-ups, squats och plank i stället för att gissa |
| **Dagens pass** | 3–5 övningar. Logga faktiskt resultat om du inte når target |
| **Adaptiv svårighet** | Levels per övning som sakta går upp eller ner |
| **Streak** | Håll vanan vid liv. Streak freezes tjänas in över tid |
| **Progress** | Levels, personliga rekord och enkel historik |
| **Settings** | Gör om assessment, nollställ data |

### Adaptionsregler

- **100% klarat** flera gånger i rad → liten ökning  
- **80–99%** → samma nivå  
- **Under 80%** upprepat → liten minskning  

Inga stora hopp. Aldrig straff. Konsistens > intensitet.

---

## Tech stack

- **Flutter** (iOS, Android, m.fl.)
- **Riverpod** — state management
- **go_router** — navigation med redirects för onboarding/assessment
- **SharedPreferences** — lokal persistens (ingen backend ännu)
- **google_fonts** — Fraunces + DM Sans

---

## Kom igång

```bash
flutter pub get
flutter run
```

Kör tester:

```bash
flutter test
flutter analyze
```

Kräver Flutter SDK som matchar `pubspec.yaml` (Dart `^3.12.2`).

---

## Arkitektur

```
lib/
  core/           # tema, delad UI-stil
  domain/         # modeller + adaption/streak-logik
  data/           # lokal lagring + repository
  providers/      # Riverpod
  features/       # onboarding, assessment, home, progress, settings
  routing/        # go_router
```

Flöde för en ny användare:

```
Onboarding → Assessment → Home (dagens pass)
                ↓
         Progress / Settings
```

Varje dag skapas ett nytt pass baserat på datum och aktuella levels. Gårdagens resultat påverkar morgondagens svårighet.

---

## Design

Minimal och lugn. Fokus ska alltid vara **dagens pass** — inte menyer, dashboards eller brus.

Motto: *Become a little stronger every day.*

---

## Framåt (ej i MVP)

- Notiser / påminnelser
- Apple Health & Google Health Connect
- Watch-stöd
- Vänner & månadsutmaningar
- Achievements & tränings­historik
- AI Coach, recovery, sömn/puls

---

## Framgång

Appen lyckas om användare:

1. Öppnar den varje dag  
2. Håller streaken vid liv  
3. Tränar regelbundet  
4. Blir lite starkare över tid  

Inte om de spenderar lång tid i appen. MomentumFit ska hjälpa dig stänga den — och börja röra på dig.
