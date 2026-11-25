
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase/supabase_config.dart';
import '../../models/profile.dart';
import '../interfaces/profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseClient get _client => SupabaseConfig.client;

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

    return Profile.fromJson(response);
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    final response = await _client
        .from('profiles')
        .update(profile.toJson())
        .eq('id', profile.id)
        .select()
        .single();

    return Profile.fromJson(response);
  }

  @override
  Future<String> uploadAvatar(File file) async {
    if (!await file.exists()) {
      throw Exception('File foto profil tidak ditemukan.');
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

    final imageUrl = _client.storage
        .from('avatars')
        .getPublicUrl(fileName);

    await _client
        .from('profiles')
        .update({'avatar_url': imageUrl})
        .eq('id', user.id);

    return imageUrl;
  }
}
