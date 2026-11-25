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
    const Profile(
      id: 'company-001',
      role: 'company',
      fullName: 'Admin PT Teknologi Nusantara',
      email: 'company@magangin.com',
    ),
    const Profile(
      id: 'admin-001',
      role: 'admin',
      fullName: 'Administrator Magangin',
      email: 'admin@magangin.com',
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

    _profiles[index] = profile;

    return profile;
  }

  @override
  Future<String> uploadAvatar(File file) async {
    if (!await file.exists()) {
      throw Exception('File foto profil tidak ditemukan.');
    }

    // Simulasi upload foto profil.
    return 'mock/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }
}