
import 'package:flutter_test/flutter_test.dart';

import 'package:magangin/repositories/mock/mock_auth_repository.dart';

void main() {
  group('Mock Auth - Student Only', () {
    late MockAuthRepository authRepository;

    setUp(() {
      authRepository = MockAuthRepository();
    });

    test('Registrasi mahasiswa berhasil', () async {
      final profile = await authRepository.signUp(
        email: 'mahasiswa.baru@example.com',
        password: 'password123',
        fullName: 'Mahasiswa Baru',
        role: 'student',
      );

      expect(profile.role, 'student');
      expect(profile.fullName, 'Mahasiswa Baru');
      expect(profile.email, 'mahasiswa.baru@example.com');
    });

    test('Registrasi role company ditolak', () async {
      expect(
        () => authRepository.signUp(
          email: 'company.baru@example.com',
          password: 'password123',
          fullName: 'Perusahaan Baru',
          role: 'company',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Registrasi role admin ditolak', () async {
      expect(
        () => authRepository.signUp(
          email: 'admin.baru@example.com',
          password: 'password123',
          fullName: 'Admin Baru',
          role: 'admin',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
