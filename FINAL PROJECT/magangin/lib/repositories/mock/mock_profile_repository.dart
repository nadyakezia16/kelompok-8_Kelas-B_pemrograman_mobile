
import 'dart:io';

import '../../models/profile.dart';
import '../interfaces/profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  final List<Profile> _profiles = [
    const Profile(
      id: 'student-001',
      role: 'student',
      fullName: 'Andi Pratama',
      email: 'student@magangin.com',
      university: 'Universitas Hasanuddin',
      major: 'Teknik Informatika',
      semester: 5,
      verificationStatus: 'verified',
    ),
  ];

  @override
  Future<Profile?> getProfile(String id) async {
    try {
      return _profiles.firstWhere(
        (profile) => profile.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    final index = _profiles.indexWhere(
      (item) => item.id == profile.id,
    );

    if (index == -1) {
      throw Exception('Profil tidak ditemukan.');
    }

    final currentProfile = _profiles[index];

    final updatedProfile = Profile(
      id: currentProfile.id,
      role: currentProfile.role,
      fullName: profile.fullName,
      email: currentProfile.email,
      phone: profile.phone,
      avatarUrl: profile.avatarUrl,
      university: profile.university,
      major: profile.major,
      semester: profile.semester,
      bio: profile.bio,
      verificationStatus: currentProfile.verificationStatus,
      verificationNote: currentProfile.verificationNote,
    );

    _profiles[index] = updatedProfile;

    return updatedProfile;
  }

  @override
  Future<String> uploadAvatar(File file) async {
    if (!await file.exists()) {
      throw Exception('File foto profil tidak ditemukan.');
    }

    return 'mock/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }
}
