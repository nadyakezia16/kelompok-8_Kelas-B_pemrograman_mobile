import 'package:flutter_test/flutter_test.dart';

import 'package:magangin/models/application.dart';
import 'package:magangin/models/job.dart';
import 'package:magangin/models/status_history.dart';

import 'package:magangin/repositories/mock/mock_job_repository.dart';
import 'package:magangin/repositories/mock/mock_company_repository.dart';
import 'package:magangin/repositories/mock/mock_application_repository.dart';
import 'package:magangin/repositories/mock/mock_auth_repository.dart';

void main() {
  group('Integrasi Mock Repository', () {
    late List<Job> sharedJobs;
    late List<Application> sharedApplications;
    late List<StatusHistory> sharedHistory;

    late MockJobRepository jobRepository;
    late MockCompanyRepository companyRepository;
    late MockApplicationRepository applicationRepository;
    late MockAuthRepository authRepository;

    setUp(() async {

      authRepository = MockAuthRepository();

      await authRepository.signIn(
        email: 'company@magangin.com',
        password: 'company123',
      );
      // Menyiapkan satu penyimpanan bersama.
      sharedJobs = [];
      sharedApplications = [];
      sharedHistory = [];

      // Membuat repository lowongan dan memasukkan data awal.
      jobRepository = MockJobRepository(sharedJobs: sharedJobs);

      // Membuat repository perusahaan dengan penyimpanan yang sama.
      companyRepository = MockCompanyRepository(
        authRepository: authRepository,
        sharedJobs: sharedJobs,
        sharedApplications: sharedApplications,
        sharedHistory: sharedHistory,
      );

      // Membuat repository lamaran dengan penyimpanan yang sama.
      applicationRepository = MockApplicationRepository(
        sharedApplications: sharedApplications,
        sharedHistory: sharedHistory,
      );
    });

    test('Lowongan MockJobRepository terbaca oleh perusahaan', () async {
      final companyJobs = await companyRepository.getMyJobs();

      expect(companyJobs, isNotEmpty);

      expect(
        companyJobs.every((job) => job.companyId == 'company-001'),
        isTrue,
      );

      final jobsFromJobRepository = await jobRepository.getJobsByCompany(
        'company-001',
      );

      expect(jobsFromJobRepository.length, companyJobs.length);
    });

    test('Lowongan baru perusahaan tersimpan di repository lowongan', () async {
      final now = DateTime.now();

      final newJob = Job(
        id: 'test-job-001',
        companyId: 'temporary-company',
        title: 'Flutter Developer Intern',
        category: 'Technology',
        location: 'Makassar',
        workType: 'Hybrid',
        durationMonths: 3,
        isPaid: true,
        allowance: 1000000,
        description: 'Lowongan untuk pengujian repository.',
        qualifications: ['Memahami Flutter'],
        benefits: ['Pengalaman kerja'],
        createdAt: now,
      );

      await companyRepository.createJob(newJob);

      final jobs = await jobRepository.getJobsByCompany('company-001');

      expect(jobs.any((job) => job.id == 'test-job-001'), isTrue);
    });

    test('Perubahan status lamaran tercatat dalam riwayat bersama', () async {
      final jobs = await companyRepository.getMyJobs();

      final application = Application(
        id: 'test-application-001',
        jobId: jobs.first.id,
        studentId: 'student-001',
        status: 'sent',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      sharedApplications.add(application);

      await companyRepository.updateApplicationStatus(
        applicationId: application.id,
        status: 'processing',
        note: 'Lamaran sedang ditinjau.',
      );

      final history = await applicationRepository.getHistory(application.id);

      expect(history, hasLength(1));
      expect(history.first.status, 'processing');
      expect(history.first.applicationId, application.id);
    });
  });
}
