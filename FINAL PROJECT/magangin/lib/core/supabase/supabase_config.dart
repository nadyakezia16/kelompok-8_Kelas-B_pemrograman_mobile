
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static Future<void> initialize() async {
    if (AppConfig.useMock) {
      return;
    }

    if (AppConfig.supabaseUrl.isEmpty ||
        AppConfig.supabaseAnonKey.isEmpty) {
      throw Exception(
        'Supabase URL dan Publishable Key belum dikonfigurasi.',
      );
    }

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
  }

  static SupabaseClient get client {
    return Supabase.instance.client;
  }
}
