/// Compile-time config. Pass key with:
/// `flutter run --dart-define=GROQ_API_KEY=...`
abstract final class CoachConfig {
  static const apiKey = String.fromEnvironment('GROQ_API_KEY');
  static const model = String.fromEnvironment(
    'GROQ_MODEL',
    defaultValue: 'llama-3.1-8b-instant',
  );

  static bool get hasApiKey => apiKey.isNotEmpty;
}
