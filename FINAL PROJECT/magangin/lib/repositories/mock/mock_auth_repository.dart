import '../../models/profile.dart';
import '../interfaces/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  Profile? _currentUser;

  final List<Profile> _users = [
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

  final Map<String, String> _passwords = {
    'student@magangin.com': 'student123',
    'company@magangin.com': 'company123',
    'admin@magangin.com': 'admin123',
  };

  @override
  Future<Profile> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final emailExists = _users.any(
          (user) => user.email.toLowerCase() == normalizedEmail,
    );

    if (emailExists) {
      throw Exception('Email sudah terdaftar.');
    }

    if (!['student', 'company', 'admin'].contains(role)) {
      throw Exception('Role tidak valid.');
    }

    final newUser = Profile(
      id: 'user-${_users.length + 1}',
      role: role,
      fullName: fullName,
      email: normalizedEmail,
      verificationStatus: 'none',
    );

    _users.add(newUser);
    _passwords[normalizedEmail] = password;
    _currentUser = newUser;

    return newUser;
  }

  @override
  Future<Profile> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final userIndex = _users.indexWhere(
          (user) => user.email.toLowerCase() == normalizedEmail,
    );

    if (userIndex == -1 ||
        _passwords[normalizedEmail] != password) {
      throw Exception('Email atau password salah.');
    }

    _currentUser = _users[userIndex];

    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  @override
  Future<Profile?> currentProfile() async {
    return _currentUser;
  }
}