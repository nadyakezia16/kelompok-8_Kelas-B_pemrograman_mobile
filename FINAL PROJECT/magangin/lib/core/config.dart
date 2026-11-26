
class AppConfig {
  AppConfig._();

  // true = menggunakan data Mock
  // false = menggunakan Supabase
  static const bool useMock = true;

  static const String appName = 'Magangin';

  // Supabase akan dikonfigurasi ketika backend siap.
  static const String supabaseUrl = 'https://ospwxhxtphavutyypgzz.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_5SSOwrFh1lYw1mS2x8dt9A_AQeMeBds';
}
