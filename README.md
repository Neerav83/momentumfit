# MomentumFit

> Become a little stronger every day.

MomentumFit är inte ännu en träningsapp för maxstyrka.

Målet är att bygga en **daglig vana**. Varje pass ska kännas görbart. Appen anpassar svårigheten så du utmanas — men aldrig överväldigas.

UI-språk: engelska. Denna README är på svenska.

---

## Principer

- Börja löjligt enkelt
- Konsistens slår intensitet
- Små förbättringar varje dag
- Personliga pass
- Streaks som motivation
- Under 5 minuter på hektiska dagar

---

## Funktioner

| Del | Vad den gör |
|---|---|
| **Onboarding** | Namn, avatar, ålder/längd/vikt, aktivitetsnivå, skador |
| **Fitness assessment** | Mäter push-ups, squats och plank i stället för att gissa |
| **Dagens pass** | 3–5 övningar. Logga faktiskt resultat (kan redigeras) |
| **Adaptiv svårighet** | Levels per övning som sakta går upp eller ner |
| **Streak** | Håll vanan vid liv. Streak freezes tjänas in över tid |
| **Progress** | Targets, PR, historik och enkla achievements |
| **AI Coach** | Offline-tips som standard; valfri nätverks-nudge med consent |
| **Reminders** | Lokala dagliga påminnelser (ställbar tid i Settings) |
| **Settings** | Notiser, AI-consent, retake assessment, nollställ data |

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
- **SQLite** + SharedPreferences — lokal persistens
- **google_fonts** — Fraunces + DM Sans
- **Groq** — valfri AI-coach via proxy (eller lokal nyckel för dev)
- **flutter_local_notifications** — lokala påminnelser (ingen Apple Push)

---

## Kom igång

```bash
flutter pub get
flutter run
```

### AI Coach

Appen använder lugna **offline-tips** som standard. Nätverks-AI kräver:

1. Opt-in under **Settings → Personalized AI nudges**
2. Antingen en **proxy-URL** (rekommenderas för store) eller en lokal Groq-nyckel (endast dev)

#### Store / produktion — proxy

Se [`proxy/README.md`](proxy/README.md). Deploya workern och kör:

```bash
flutter run --dart-define=COACH_PROXY_URL=https://your-worker.example
```

Nyckeln ligger då **inte** i app-binären.

#### Lokal utveckling — direkt nyckel

```bash
cp local_defines.example.json local_defines.json
# fyll i GROQ_API_KEY
flutter run --dart-define-from-file=local_defines.json
```

**Varning:** `GROQ_API_KEY` via `--dart-define` bäddas in i binären. Använd inte det för store-builds.

Coach-texten cachas en gång per dag + scenario. Namn och skador skickas **inte** till AI som standard.

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
  core/           # tema, delade widgets
  domain/         # modeller + adaption/streak/achievements
  data/           # lokal lagring + repository + AI-klient
  providers/      # Riverpod
  features/       # onboarding, assessment, home, progress, settings
  routing/        # go_router
proxy/            # Cloudflare Worker för Groq-nyckel
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

## Framåt

Klart:

- Lokala notiser / påminnelser
- Achievements & träningshistorik
- Groq-proxy + AI-consent
- Streak-freeze-korrekthet, säkrare SQLite-skrivningar

Senare:

- Apple Health & Google Health Connect
- Watch-stöd
- Vänner & månadsutmaningar
- Recovery, sömn/puls
- Svensk i18n (ARB)

---

## Framgång

Appen lyckas om användare:

1. Öppnar den varje dag  
2. Håller streaken vid liv  
3. Tränar regelbundet  
4. Blir lite starkare över tid  

Inte om de spenderar lång tid i appen. MomentumFit ska hjälpa dig stänga den — och börja röra på dig.
