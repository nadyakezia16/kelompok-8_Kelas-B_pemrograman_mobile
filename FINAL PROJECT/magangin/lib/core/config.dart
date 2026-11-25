
class AppConfig {
  AppConfig._();

  // true = menggunakan data Mock
  // false = menggunakan Supabase
  static const bool useMock = true;

  static const String appName = 'Magangin';

  // Supabase akan dikonfigurasi ketika backend siap.
  static const String supabaseUrl = '';
  static const String supabaseAnonKey = '';
}
