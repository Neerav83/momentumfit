# Träningsplanerare Implementation

## Översikt

Denna implementation lägger till en AI-driven träningsplanerare där användare kan ha konversationer med en AI-coach för att diskutera och planera personliga träningsprogram.

## Funktioner

### 1. Konversationshantering
- Skapa nya konversationer
- Visa lista över tidigare konversationer
- Ta bort konversationer
- Automatisk titel från första meddelandet

### 2. Chat-gränssnitt
- Chattbubblor för användare och AI
- Realtids-indikator när AI genererar svar
- Responsiv design (stöder både mobil och desktop)
- Automatisk scroll till senaste meddelandet

### 3. AI-Integration
- Använder Groq API (via proxy eller direkt)
- Kontextmedvetna svar baserat på konversationshistorik
- Inkluderar användarprofil (ålder, aktivitetsnivå, skador)
- Flerspråkigt stöd (svenska/engelska)

## Teknisk Implementation

### Nya filer

#### Models
- `lib/domain/models/chat_message.dart` - Chattmeddelande-modell
- `lib/domain/models/workout_conversation.dart` - Konversations-modell

#### Data Layer
- `lib/data/ai/workout_planner_client.dart` - AI-klient för konversationer
- Uppdaterad `lib/data/local/app_database.dart` - Databas version 3 med nya tabeller

#### UI
- `lib/features/workout_planner/workout_planner_screen.dart` - Huvudskärm
- `lib/features/workout_planner/widgets/chat_bubble.dart` - Chat-bubbla widget
- `lib/features/workout_planner/widgets/conversation_list_item.dart` - Konversations-listpost

#### State Management
- `lib/providers/workout_planner_provider.dart` - Riverpod state management

#### Routing & i18n
- Uppdaterad `lib/routing/app_router.dart` - Ny route `/workout-planner`
- Uppdaterad `lib/features/settings/settings_screen.dart` - Länk till träningsplanerare
- Nya översättningar i `lib/l10n/app_sv.arb` och `lib/l10n/app_en.arb`

#### Proxy
- Uppdaterad `proxy/worker.js` - Stöd för fullständiga konversationer

### Databas-schema

```sql
CREATE TABLE workout_conversations (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  is_archived INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE chat_messages (
  id TEXT PRIMARY KEY,
  conversation_id TEXT NOT NULL,
  role TEXT NOT NULL,
  content TEXT NOT NULL,
  timestamp TEXT NOT NULL,
  FOREIGN KEY (conversation_id) REFERENCES workout_conversations (id) ON DELETE CASCADE
);
```

## Användning

### För Användare

1. Öppna **Settings** från huvudnavigationen
2. Under **Verktyg/Tools**, klicka på **Träningsplanerare**
3. Skriv ditt första meddelande, t.ex.:
   ```
   Jag vill ha ett program för en 47 åring. 
   Det ska köras varje morgon 15 minuter direkt när jag går upp. 
   Jag har hört om military calisthenics. Vad tror du om den typen av träning för mig?
   ```
4. AI:n kommer att svara med personliga råd baserat på din profil
5. Fortsätt konversationen för att förfina träningsplanen
6. Tidigare konversationer sparas och kan återupptag as när som helst

### För Utvecklare

#### Kör appen
```bash
flutter pub get
flutter run --dart-define-from-file=local_defines.json
```

#### Testa med proxy (produktion)
```bash
# Deploya worker till Cloudflare
cd proxy
# Följ instruktioner i proxy/README.md

# Kör appen med proxy
flutter run --dart-define=COACH_PROXY_URL=https://your-worker.workers.dev
```

## AI Prompt Design

AI:n är konfigurerad att:
- Förstå användarens bakgrund, mål och begränsningar
- Ge konkreta, personliga råd
- Skapa realistiska och hållbara träningsprogram
- Anpassa efter ålder, erfarenhet och skador
- Vara stöttande utan att vara över-entusiastisk
- Aldrig ge medicinska råd

Exempel på systemprompt (svenska):
```
Du är en personlig träningscoach som hjälper användare att planera träningsprogram.

Ditt mål är att:
- Förstå användarens bakgrund, mål, begränsningar och preferenser
- Ge konkreta, personliga råd baserat på deras situation
- Skapa anpassade träningsprogram som är realistiska och hållbara
- Vara stöttande, ärlig och uppmuntrande utan att vara över-entusiastisk
- Aldrig ge medicinska råd eller rekommendera något som kan vara farligt
```

## Framtida Förbättringar

- [ ] Export av träningsplan till dagliga pass i appen
- [ ] Dela träningsplaner med vänner
- [ ] Spara favorit-träningsprogram som mallar
- [ ] Röstinput för meddelanden
- [ ] Bildstöd för att visa övningar
- [ ] Integration med befintliga workouts för uppföljning
- [ ] Notifikationer när AI svarar (om konversation är i bakgrunden)

## Testning

### Manuell testplan

1. **Skapa ny konversation**
   - [ ] Öppna workout planner från settings
   - [ ] Skriv ett meddelande
   - [ ] Verifiera att konversation skapas automatiskt
   - [ ] Verifiera att titel genereras från första meddelandet

2. **Chat-funktionalitet**
   - [ ] Skicka flera meddelanden i rad
   - [ ] Verifiera att AI svarar med relevant innehåll
   - [ ] Verifiera att konversationshistorik bibehålls
   - [ ] Verifiera att scroll fungerar automatiskt

3. **Konversationshantering**
   - [ ] Skapa flera konversationer
   - [ ] Byt mellan konversationer
   - [ ] Ta bort en konversation
   - [ ] Starta ny konversation från befintlig lista

4. **Responsiv design**
   - [ ] Testa på smal skärm (mobil)
   - [ ] Testa på bred skärm (tablet/desktop)
   - [ ] Verifiera att layout anpassas korrekt

5. **Flerspråk**
   - [ ] Byt språk till engelska i settings
   - [ ] Verifiera att UI översätts
   - [ ] Verifiera att AI svarar på engelska
   - [ ] Byt tillbaka till svenska

6. **Användarprofil-integration**
   - [ ] Verifiera att AI tar hänsyn till ålder
   - [ ] Verifiera att AI tar hänsyn till aktivitetsnivå
   - [ ] Verifiera att AI tar hänsyn till skador

## Notes

- Databas migrering från v2 till v3 är bakåtkompatibel
- Proxy stöder både gamla formatet (system+user) och nya (messages array)
- AI-generering kräver aktiv internetanslutning och AI-consent i settings
- Konversationer sparas lokalt i SQLite och är privata
