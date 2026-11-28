
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase/avatar_url_helper.dart';
import '../../core/supabase/supabase_config.dart';
import '../../models/profile.dart';
import '../interfaces/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  Future<Profile> _profileFromResponse(
    Map<String, dynamic> response,
  ) async {
    final profile = Profile.fromJson(response);

    final avatarUrl = await AvatarUrlHelper.resolve(
      profile.avatarUrl,
    );

    return Profile(
      id: profile.id,
      role: profile.role,
      fullName: profile.fullName,
      email: profile.email,
      phone: profile.phone,
      avatarUrl: avatarUrl,
      university: profile.university,
      major: profile.major,
      semester: profile.semester,
      bio: profile.bio,
      verificationStatus: profile.verificationStatus,
      verificationNote: profile.verificationNote,
    );
  }

  @override
  Future<Profile> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    if (role != 'student') {
      throw Exception(
        'Registrasi hanya tersedia untuk mahasiswa.',
      );
    }

    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role,
      },
    );

    final user = response.user;

    if (user == null) {
      throw Exception('Registrasi gagal. Silakan coba kembali.');
    }

    final profileResponse = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (profileResponse == null) {
      throw Exception(
        'Akun berhasil dibuat, tetapi profil belum tersedia.',
      );
    }

    return _profileFromResponse(profileResponse);
  }

  @override
  Future<Profile> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user == null) {
      throw Exception('Login gagal. Pengguna tidak ditemukan.');
    }

    final profileResponse = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (profileResponse == null) {
      throw Exception('Profil pengguna tidak ditemukan.');
    }

    return _profileFromResponse(profileResponse);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<Profile?> currentProfile() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      return null;
    }

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return _profileFromResponse(response);
  }
}
