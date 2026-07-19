/// Compile-time coach config.
///
/// Prefer a server-side proxy for store builds:
/// `flutter run --dart-define=COACH_PROXY_URL=https://your-proxy.example`
///
/// Direct Groq key is for local development only and is embedded in the binary:
/// `flutter run --dart-define-from-file=local_defines.json`
abstract final class CoachConfig {
  static const apiKey = String.fromEnvironment('GROQ_API_KEY');
  static const proxyUrl = String.fromEnvironment('COACH_PROXY_URL');
  static const model = String.fromEnvironment(
    'GROQ_MODEL',
    defaultValue: 'llama-3.1-8b-instant',
  );

  static bool get hasProxy => proxyUrl.trim().isNotEmpty;

  /// Direct client key — avoid shipping this in store builds.
  static bool get hasApiKey => apiKey.isNotEmpty;

  static bool get isNetworkEnabled => hasProxy || hasApiKey;
}
