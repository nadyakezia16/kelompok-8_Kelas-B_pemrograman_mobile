
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

class AvatarUrlHelper {
  static SupabaseClient get _client => SupabaseConfig.client;

  static Future<String?> resolve(String? storagePath) async {
    if (storagePath == null || storagePath.isEmpty) {
      return null;
    }

    // Mendukung URL lama jika sebelumnya tersimpan di database.
    if (storagePath.startsWith('https://') ||
        storagePath.startsWith('http://')) {
      return storagePath;
    }

    try {
      return await _client.storage
          .from('avatars')
          .createSignedUrl(storagePath, 3600);
    } catch (_) {
      // Foto tidak tersedia tidak boleh menggagalkan pemuatan profil.
      return null;
    }
  }
}
