
import 'package:flutter_test/flutter_test.dart';

import '../lib/models/company.dart';
import '../lib/repositories/mock/mock_auth_repository.dart';
import '../lib/repositories/mock/mock_company_repository.dart';

void main() {
  late MockAuthRepository authRepository;
  late MockCompanyRepository companyRepository;

  setUp(() {
    authRepository = MockAuthRepository();

    companyRepository = MockCompanyRepository(
      authRepository: authRepository,
    );
  });

  test('Pengguna yang belum login tidak bisa mengakses perusahaan', () async {
    await expectLater(
      companyRepository.getMyCompany(),
      throwsA(isA<Exception>()),
    );
  });

  test('Akun mahasiswa tidak bisa mengakses fitur perusahaan', () async {
    await authRepository.signIn(
      email: 'student@magangin.com',
      password: 'student123',
    );

    await expectLater(
      companyRepository.getMyCompany(),
      throwsA(isA<Exception>()),
    );
  });

  test('Perusahaan tidak bisa mengubah identitas perusahaannya', () async {
    await authRepository.signIn(
      email: 'company@magangin.com',
      password: 'company123',
    );

    await expectLater(
      companyRepository.updateCompany(
        const Company(
          id: 'company-999',
          name: 'Perusahaan Palsu',
        ),
      ),
      throwsA(isA<Exception>()),
    );
  });
}
