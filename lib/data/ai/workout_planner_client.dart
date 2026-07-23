import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/coach_config.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/user_profile.dart';

class WorkoutPlannerClient {
  WorkoutPlannerClient({http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final http.Client _http;

  Future<String?> generateResponse({
    required List<ChatMessage> conversationHistory,
    required String userMessage,
    UserProfile? userProfile,
    String languageCode = 'en',
  }) async {
    if (!CoachConfig.isNetworkEnabled) return null;

    final isSwedish = languageCode == 'sv';
    
    final systemPrompt = _buildSystemPrompt(
      isSwedish: isSwedish,
      userProfile: userProfile,
    );
    
    final messages = _buildMessages(
      conversationHistory: conversationHistory,
      userMessage: userMessage,
      systemPrompt: systemPrompt,
    );

    try {
      if (CoachConfig.hasProxy) {
        return _postProxy(messages: messages);
      }
      return _postGroqDirect(messages: messages);
    } catch (_) {
      return null;
    }
  }

  String _buildSystemPrompt({
    required bool isSwedish,
    UserProfile? userProfile,
  }) {
    final basePrompt = isSwedish
        ? '''Du är en personlig träningscoach som hjälper användare att planera träningsprogram.

Ditt mål är att:
- Förstå användarens bakgrund, mål, begränsningar och preferenser
- Ge konkreta, personliga råd baserat på deras situation
- Skapa anpassade träningsprogram som är realistiska och hållbara
- Vara stöttande, ärlig och uppmuntrande utan att vara över-entusiastisk
- Aldrig ge medicinska råd eller rekommendera något som kan vara farligt

När du skapar träningsprogram:
- Anpassa efter ålder, erfarenhetsnivå och eventuella skador
- Föreslå övningar med tydliga instruktioner
- Inkludera uppvärmning och nedvarvning
- Vara realistisk om tid och svårighetsgrad
- Fokusera på långsiktig hållbarhet framför kortsiktiga resultat

Skriv alltid på svenska. Använd naturlig, vänlig svenska utan överdrivna hälsningar eller emojis.'''
        : '''You are a personal fitness coach helping users plan workout programs.

Your goal is to:
- Understand the user's background, goals, limitations, and preferences
- Give concrete, personalized advice based on their situation
- Create custom workout programs that are realistic and sustainable
- Be supportive, honest, and encouraging without being overly enthusiastic
- Never give medical advice or recommend anything that could be dangerous

When creating workout programs:
- Adapt to age, experience level, and any injuries
- Suggest exercises with clear instructions
- Include warm-up and cool-down
- Be realistic about time and difficulty
- Focus on long-term sustainability over short-term results

Always write in English. Use natural, friendly language without excessive greetings or emojis.''';

    if (userProfile != null) {
      final profileInfo = isSwedish
          ? '\n\nAnvändarens profil:\n'
              '- Ålder: ${userProfile.age} år\n'
              '- Aktivitetsnivå: ${userProfile.activityLevel.name}\n'
              '- Skador/begränsningar: ${userProfile.injuries.map((e) => e.name).join(", ")}'
          : '\n\nUser profile:\n'
              '- Age: ${userProfile.age} years\n'
              '- Activity level: ${userProfile.activityLevel.name}\n'
              '- Injuries/limitations: ${userProfile.injuries.map((e) => e.name).join(", ")}';
      return basePrompt + profileInfo;
    }

    return basePrompt;
  }

  List<Map<String, String>> _buildMessages({
    required List<ChatMessage> conversationHistory,
    required String userMessage,
    required String systemPrompt,
  }) {
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    for (final msg in conversationHistory) {
      if (msg.role != MessageRole.system) {
        messages.add({
          'role': msg.role == MessageRole.user ? 'user' : 'assistant',
          'content': msg.content,
        });
      }
    }

    messages.add({'role': 'user', 'content': userMessage});

    return messages;
  }

  Future<String?> _postProxy({
    required List<Map<String, String>> messages,
  }) async {
    final uri = Uri.parse(CoachConfig.proxyUrl);
    final response = await _http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'model': CoachConfig.model,
            'messages': messages,
            'temperature': 0.7,
            'max_tokens': 1500,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final text = (body['text'] as String?)?.trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  Future<String?> _postGroqDirect({
    required List<Map<String, String>> messages,
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
            'model': CoachConfig.model,
            'temperature': 0.7,
            'max_tokens': 1500,
            'messages': messages,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = body['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) return null;

    final message = choices.first as Map<String, dynamic>;
    final content =
        (message['message'] as Map<String, dynamic>?)?['content'] as String?;
    final text = content?.trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  void dispose() => _http.close();
}
