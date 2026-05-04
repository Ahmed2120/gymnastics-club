class SupabaseConstants {
  // Values are injected at build time via --dart-define-from-file=.env.json
  // Never hardcode secrets here. See .env.json.example for the required keys.
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
