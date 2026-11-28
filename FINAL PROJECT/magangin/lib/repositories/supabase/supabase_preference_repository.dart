
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase/supabase_config.dart';
import '../../models/preference.dart';
import '../interfaces/preference_repository.dart';

class SupabasePreferenceRepository implements PreferenceRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  @override
  Future<Preference?> getPreferences() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    final response = await _client
        .from('preferences')
        .select()
        .eq('student_id', user.id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Preference.fromJson(response);
  }

  @override
  Future<Preference> savePreferences(Preference preference) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    final data = preference.toJson();

    // Pastikan preferensi disimpan untuk pengguna yang sedang login.
    data['student_id'] = user.id;

    // Perbarui waktu terakhir preferensi disimpan.
    data['updated_at'] = DateTime.now().toUtc().toIso8601String();

    final response = await _client
        .from('preferences')
        .upsert(
      data,
      onConflict: 'student_id',
    )
        .select()
        .single();

    return Preference.fromJson(response);
  }
}
