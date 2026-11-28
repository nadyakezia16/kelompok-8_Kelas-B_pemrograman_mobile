
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase/avatar_url_helper.dart';
import '../../core/supabase/supabase_config.dart';
import '../../models/profile.dart';
import '../interfaces/profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  static const int _maxAvatarSize = 2 * 1024 * 1024;

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
  Future<Profile?> getProfile(String id) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return _profileFromResponse(response);
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    if (profile.id != user.id) {
      throw Exception('Anda tidak dapat mengubah profil pengguna lain.');
    }

    final response = await _client
        .from('profiles')
        .update({
          'full_name': profile.fullName,
          'phone': profile.phone,
          'university': profile.university,
          'major': profile.major,
          'semester': profile.semester,
          'bio': profile.bio,
        })
        .eq('id', user.id)
        .select()
        .single();

    return _profileFromResponse(response);
  }

  @override
  Future<String> uploadAvatar(File file) async {
    if (!await file.exists()) {
      throw Exception('File foto profil tidak ditemukan.');
    }

    final fileSize = await file.length();

    if (fileSize > _maxAvatarSize) {
      throw Exception('Ukuran foto profil maksimal 2 MB.');
    }

    final extension = file.path.split('.').last.toLowerCase();

    const allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

    if (!allowedExtensions.contains(extension)) {
      throw Exception(
        'Format foto harus JPG, JPEG, PNG, atau WEBP.',
      );
    }

    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    final fileName =
        '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.$extension';

    await _client.storage
        .from('avatars')
        .upload(fileName, file);

    // Simpan Storage Path, bukan Signed URL.
    await _client
        .from('profiles')
        .update({'avatar_url': fileName})
        .eq('id', user.id);

    // Signed URL hanya digunakan oleh aplikasi untuk menampilkan foto.
    final imageUrl = await AvatarUrlHelper.resolve(fileName);

    if (imageUrl == null) {
      throw Exception('Gagal membuat URL foto profil.');
    }

    return imageUrl;
  }
}
