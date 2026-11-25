
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase/supabase_config.dart';
import '../../models/profile.dart';
import '../interfaces/admin_repository.dart';

class SupabaseAdminRepository implements AdminRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  @override
  Future<List<Profile>> getPendingVerifications() async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('role', 'student')
        .eq('verification_status', 'pending')
        .order('full_name', ascending: true);

    return (response as List)
        .map((item) => Profile.fromJson(item))
        .toList();
  }

  @override
  Future<void> approve(String studentId) async {
    final response = await _client
        .from('profiles')
        .update({
      'verification_status': 'verified',
      'verification_note': null,
    })
        .eq('id', studentId)
        .eq('role', 'student')
        .eq('verification_status', 'pending')
        .select('id');

    if ((response as List).isEmpty) {
      throw Exception(
        'Mahasiswa tidak ditemukan atau sudah diproses.',
      );
    }
  }

  @override
  Future<void> reject({
    required String studentId,
    required String reason,
  }) async {
    if (reason.trim().isEmpty) {
      throw Exception('Alasan penolakan wajib diisi.');
    }

    final response = await _client
        .from('profiles')
        .update({
      'verification_status': 'rejected',
      'verification_note': reason.trim(),
    })
        .eq('id', studentId)
        .eq('role', 'student')
        .eq('verification_status', 'pending')
        .select('id');

    if ((response as List).isEmpty) {
      throw Exception(
        'Mahasiswa tidak ditemukan atau sudah diproses.',
      );
    }
  }
}
