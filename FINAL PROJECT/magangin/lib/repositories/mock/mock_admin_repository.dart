
import '../../models/profile.dart';
import '../interfaces/admin_repository.dart';

class MockAdminRepository implements AdminRepository {
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
      id: 'student-002',
      role: 'student',
      fullName: 'Siti Rahma',
      email: 'siti@magangin.com',
      university: 'Universitas Hasanuddin',
      major: 'Sistem Informasi',
      semester: 4,
      verificationStatus: 'pending',
    ),
    const Profile(
      id: 'student-003',
      role: 'student',
      fullName: 'Budi Santoso',
      email: 'budi@magangin.com',
      university: 'Universitas Negeri Makassar',
      major: 'Pendidikan Teknik Informatika',
      semester: 6,
      verificationStatus: 'pending',
    ),
  ];

  @override
  Future<List<Profile>> getPendingVerifications() async {
    return List.unmodifiable(
      _profiles.where(
            (profile) => profile.verificationStatus == 'pending',
      ),
    );
  }

  @override
  Future<void> approve(String studentId) async {
    final index = _profiles.indexWhere(
          (profile) => profile.id == studentId,
    );

    if (index == -1) {
      throw Exception('Mahasiswa tidak ditemukan.');
    }

    final profile = _profiles[index];

    if (profile.verificationStatus != 'pending') {
      throw Exception('Mahasiswa tidak sedang menunggu verifikasi.');
    }

    _profiles[index] = _copyWithVerification(
      profile,
      status: 'verified',
    );
  }

  @override
  Future<void> reject({
    required String studentId,
    required String reason,
  }) async {
    if (reason.trim().isEmpty) {
      throw Exception('Alasan penolakan harus diisi.');
    }

    final index = _profiles.indexWhere(
          (profile) => profile.id == studentId,
    );

    if (index == -1) {
      throw Exception('Mahasiswa tidak ditemukan.');
    }

    final profile = _profiles[index];

    if (profile.verificationStatus != 'pending') {
      throw Exception('Mahasiswa tidak sedang menunggu verifikasi.');
    }

    _profiles[index] = _copyWithVerification(
      profile,
      status: 'rejected',
      note: reason,
    );
  }

  Profile _copyWithVerification(
      Profile profile, {
        required String status,
        String? note,
      }) {
    return Profile(
      id: profile.id,
      role: profile.role,
      fullName: profile.fullName,
      email: profile.email,
      phone: profile.phone,
      avatarUrl: profile.avatarUrl,
      university: profile.university,
      major: profile.major,
      semester: profile.semester,
      bio: profile.bio,
      verificationStatus: status,
      verificationNote: note,
    );
  }
}
