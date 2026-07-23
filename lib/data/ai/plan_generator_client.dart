import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/coach_config.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/custom_workout_plan.dart';
import '../../domain/models/user_profile.dart';

class PlanGeneratorClient {
  PlanGeneratorClient({http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final http.Client _http;

  Future<CustomWorkoutPlan?> generatePlanFromConversation({
    required String conversationId,
    required List<ChatMessage> conversationHistory,
    UserProfile? userProfile,
    String languageCode = 'en',
  }) async {
    if (!CoachConfig.isNetworkEnabled) return null;

    final isSwedish = languageCode == 'sv';
    
    final systemPrompt = _buildSystemPrompt(isSwedish: isSwedish);
    final userPrompt = _buildUserPrompt(
      conversationHistory: conversationHistory,
      userProfile: userProfile,
      isSwedish: isSwedish,
    );

    try {
      String? jsonResponse;
      if (CoachConfig.hasProxy) {
        jsonResponse = await _postProxy(
          systemPrompt: systemPrompt,
          userPrompt: userPrompt,
        );
      } else {
        jsonResponse = await _postGroqDirect(
          systemPrompt: systemPrompt,
          userPrompt: userPrompt,
        );
      }

      if (jsonResponse == null) return null;

      return _parsePlanFromJson(
        jsonResponse,
        conversationId,
        conversationHistory,
      );
    } catch (_) {
      return null;
    }
  }

  String _buildSystemPrompt({required bool isSwedish}) {
    if (isSwedish) {
      return '''Du är en träningsplanerare som skapar strukturerade träningsprogram.

Din uppgift är att analysera konversationen och skapa en konkret, strukturerad veckoplan.

Du måste svara med ENDAST giltigt JSON i följande format (ingen annan text):
{
  "name": "Namnet på träningsprogrammet",
  "description": "Kort beskrivning av programmet",
  "weeklySchedule": [
    {
      "dayOfWeek": 1,
      "isRestDay": false,
      "exercises": [
        {
          "exerciseId": "push_ups",
          "targetReps": 15,
          "sets": 3,
          "restSeconds": 60,
          "notes": "Fokusera på formen"
        }
      ],
      "notes": "Morgonpass - 15 minuter"
    }
  ]
}

Tillgängliga exerciseId (använd ENDAST dessa):
- push_ups (Armhävningar)
- knee_push_ups (Knäarmhävningar)
- chair_dips (Stoldips)
- squats (Knäböj)
- lunges (Utfall)
- glute_bridge (Höftlyft)
- calf_raises (Tåhävningar)
- plank (Plankan - sekunder istället för reps)
- side_plank (Sidplankan - sekunder)
- dead_bug (Dödskalbaggen)
- bird_dog (Fågelhund)
- jumping_jacks (Hopptomtar)
- high_knees (Höga knän)
- mountain_climbers (Bergsklättrare)

dayOfWeek: 1=Måndag, 2=Tisdag, 3=Onsdag, 4=Torsdag, 5=Fredag, 6=Lördag, 7=Söndag
isRestDay: true för vilodagar (då exercises är tom array)
targetReps: antal repetitioner ELLER sekunder (för plank/side_plank)
sets: antal set (vanligtvis 1-4)

Skapa ett realistiskt program baserat på konversationen.''';
    }

    return '''You are a workout planner creating structured training programs.

Your task is to analyze the conversation and create a concrete, structured weekly plan.

You must respond with ONLY valid JSON in this format (no other text):
{
  "name": "Training Program Name",
  "description": "Brief description of the program",
  "weeklySchedule": [
    {
      "dayOfWeek": 1,
      "isRestDay": false,
      "exercises": [
        {
          "exerciseId": "push_ups",
          "targetReps": 15,
          "sets": 3,
          "restSeconds": 60,
          "notes": "Focus on form"
        }
      ],
      "notes": "Morning session - 15 minutes"
    }
  ]
}

Available exerciseId (use ONLY these):
- push_ups
- knee_push_ups
- chair_dips
- squats
- lunges
- glute_bridge
- calf_raises
- plank (seconds instead of reps)
- side_plank (seconds)
- dead_bug
- bird_dog
- jumping_jacks
- high_knees
- mountain_climbers

dayOfWeek: 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday, 7=Sunday
isRestDay: true for rest days (then exercises is empty array)
targetReps: number of repetitions OR seconds (for plank/side_plank)
sets: number of sets (typically 1-4)

Create a realistic program based on the conversation.''';
  }

  String _buildUserPrompt({
    required List<ChatMessage> conversationHistory,
    UserProfile? userProfile,
    required bool isSwedish,
  }) {
    final buffer = StringBuffer();
    
    if (isSwedish) {
      buffer.writeln('Konversation:');
    } else {
      buffer.writeln('Conversation:');
    }
    
    for (final msg in conversationHistory) {
      final role = msg.role == MessageRole.user ? 'Användare' : 'Coach';
      buffer.writeln('$role: ${msg.content}');
    }

    if (userProfile != null) {
      if (isSwedish) {
        buffer.writeln('\nAnvändarprofil:');
        buffer.writeln('- Ålder: ${userProfile.age}');
        buffer.writeln('- Aktivitetsnivå: ${userProfile.activityLevel.name}');
        buffer.writeln('- Skador: ${userProfile.injuries.map((e) => e.name).join(", ")}');
      } else {
        buffer.writeln('\nUser profile:');
        buffer.writeln('- Age: ${userProfile.age}');
        buffer.writeln('- Activity level: ${userProfile.activityLevel.name}');
        buffer.writeln('- Injuries: ${userProfile.injuries.map((e) => e.name).join(", ")}');
      }
    }

    if (isSwedish) {
      buffer.writeln('\nSkapa nu en strukturerad veckoplan baserat på ovanstående. Svara ENDAST med JSON.');
    } else {
      buffer.writeln('\nNow create a structured weekly plan based on the above. Respond ONLY with JSON.');
    }

    return buffer.toString();
  }

  CustomWorkoutPlan? _parsePlanFromJson(
    String jsonString,
    String conversationId,
    List<ChatMessage> history,
  ) {
    try {
      String cleanJson = jsonString.trim();
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      }
      if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson.substring(3);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }
      cleanJson = cleanJson.trim();

      final json = jsonDecode(cleanJson) as Map<String, dynamic>;
      
      final name = json['name'] as String;
      final description = json['description'] as String?;
      final scheduleJson = json['weeklySchedule'] as List<dynamic>;

      final schedule = scheduleJson
          .map((e) => DayWorkout.fromJson(e as Map<String, dynamic>))
          .toList();

      return CustomWorkoutPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        weeklySchedule: schedule,
        createdAt: DateTime.now(),
        conversationId: conversationId,
        isActive: false,
      );
    } catch (e) {
      return null;
    }
  }

  Future<String?> _postProxy({
    required String systemPrompt,
    required String userPrompt,
  }) async {
    final uri = Uri.parse(CoachConfig.proxyUrl);
    final response = await _http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'model': 'llama-3.1-70b-versatile',
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': userPrompt},
            ],
            'temperature': 0.3,
            'max_tokens': 2000,
          }),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['text'] as String?)?.trim();
  }

  Future<String?> _postGroqDirect({
    required String systemPrompt,
    required String userPrompt,
  }) async {
    final uri = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    final response = await _http
        .post(
          uri,
          headers: {
            'Authorization': 'Bearer ${CoachConfig.apiKey}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': 'llama-3.1-70b-versatile',
            'temperature': 0.3,
            'max_tokens': 2000,
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': userPrompt},
            ],
          }),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = body['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) return null;

    final message = choices.first as Map<String, dynamic>;
    final content =
        (message['message'] as Map<String, dynamic>?)?['content'] as String?;
    return content?.trim();
  }

  void dispose() => _http.close();
}
