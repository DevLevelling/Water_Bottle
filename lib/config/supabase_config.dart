/// Supabase configuration that reads values from compile-time environment.
///
/// Provide values via --dart-define when running or building, for example:
///   flutter run \
///     --dart-define=SUPABASE_URL=... \
///     --dart-define=SUPABASE_ANON_KEY=...
class SupabaseConfig {
  // Supabase project credentials from environment
  static const String url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  // Configuration options
  static const bool enableDebug = false;
}
