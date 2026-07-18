import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/coach_config.dart';
import '../../domain/services/coach_insights.dart';

class GroqCoachClient {
  GroqCoachClient({http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final http.Client _http;
  static final _uri =
      Uri.parse('https://api.groq.com/openai/v1/chat/completions');

  Future<String?> generateNudge(CoachInsights insights) async {
    if (!CoachConfig.hasApiKey) return null;

    final scenario = insights.scenario.name;
    final facts = insights.factsForPrompt.join('\n');

    final userPrompt = '''
Scenario to address: $scenario

Real user data (use concrete numbers from this — never invent stats):
$facts

Write a personal coach message for the home screen (2–4 short sentences).
Rules:
- Reference real data above whenever possible (streaks, reps, seconds, % improvement, PRs).
- Sound like a calm, honest supportive personal trainer.
- Never shame. No toxic motivation. No hype. No emojis. No bullet lists unless scenario is monthlySummary.
- Do not give medical advice. Do not invent new workout targets.
- If scenario is monthlySummary, include the month stats clearly.
''';

    final response = await _http
        .post(
          _uri,
          headers: {
            'Authorization': 'Bearer ${CoachConfig.apiKey}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': CoachConfig.model,
            'temperature': 0.55,
            'max_tokens': 180,
            'messages': [
              {
                'role': 'system',
                'content':
                    'You are MomentumFit\'s personal habit coach. '
                    'Motto: Become a little stronger every day. '
                    'Every message must feel personal and grounded in the user\'s real workout history. '
                    'Never write generic motivational quotes.',
              },
              {
                'role': 'user',
                'content': userPrompt,
              },
            ],
          }),
        )
        .timeout(const Duration(seconds: 15));

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
