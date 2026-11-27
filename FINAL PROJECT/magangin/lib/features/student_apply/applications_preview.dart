
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config.dart';
import '../../core/theme/app_theme.dart';
import '../../models/application.dart';
import '../../models/company.dart';
import '../../models/job.dart';
import '../../models/status_history.dart';
import '../../repositories/interfaces/application_repository.dart';
import 'applications_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ApplicationsPreviewApp());
}

class ApplicationsPreviewApp extends StatelessWidget {
  const ApplicationsPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<ApplicationRepository>(
      create: (_) => _PreviewApplicationRepository(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConfig.appName,
        theme: AppTheme.lightTheme,
        home: const ApplicationsScreen(),
      ),
    );
  }
}

class _PreviewApplicationRepository
    implements ApplicationRepository {
  final List<Application> _applications = [
    Application(
      id: 'preview-1',
      jobId: 'job-1',
      studentId: 'preview-user',
      status: 'sent',
      createdAt: DateTime(2026, 11, 5),
      updatedAt: DateTime(2026, 11, 5),
      job: Job(
        id: 'job-1',
        companyId: 'company-1',
        title: 'Digital Marketing Intern',
        category: 'Marketing',
        location: 'Jakarta (Hybrid)',
        workType: 'hybrid',
        durationMonths: 3,
        isPaid: true,
        allowance: 1500000,
        description: 'Program magang Digital Marketing.',
        qualifications: [],
        benefits: [],
        createdAt: DateTime(2026, 10, 1),
        company: const Company(
          id: 'company-1',
          name: 'Telkomsel',
          industry: 'Telekomunikasi',
        ),
      ),
    ),
    Application(
      id: 'preview-2',
      jobId: 'job-2',
      studentId: 'preview-user',
      status: 'interview',
      createdAt: DateTime(2026, 11, 14),
      updatedAt: DateTime(2026, 11, 20),
      job: Job(
        id: 'job-2',
        companyId: 'company-2',
        title: 'UI/UX Designer Intern',
        category: 'Design',
        location: 'Jakarta',
        workType: 'onsite',
        durationMonths: 3,
        isPaid: true,
        allowance: 2000000,
        description: 'Program magang UI/UX Designer.',
        qualifications: [],
        benefits: [],
        createdAt: DateTime(2026, 10, 2),
        company: const Company(
          id: 'company-2',
          name: 'Tokopedia',
          industry: 'E-commerce',
        ),
      ),
    ),
    Application(
      id: 'preview-3',
      jobId: 'job-3',
      studentId: 'preview-user',
      status: 'accepted',
      createdAt: DateTime(2026, 11, 10),
      updatedAt: DateTime(2026, 11, 20),
      companyNote: 'Selamat! Lamaran kamu diterima.',
      job: Job(
        id: 'job-3',
        companyId: 'company-3',
        title: 'Frontend Developer Intern',
        category: 'Technology',
        location: 'Jakarta (Hybrid)',
        workType: 'hybrid',
        durationMonths: 6,
        isPaid: true,
        allowance: 2500000,
        description: 'Program magang Frontend Developer.',
        qualifications: [],
        benefits: [],
        createdAt: DateTime(2026, 10, 3),
        company: const Company(
          id: 'company-3',
          name: 'Gojek',
          industry: 'Teknologi',
        ),
      ),
    ),
    Application(
      id: 'preview-4',
      jobId: 'job-4',
      studentId: 'preview-user',
      status: 'rejected',
      createdAt: DateTime(2026, 11, 1),
      updatedAt: DateTime(2026, 11, 8),
      job: Job(
        id: 'job-4',
        companyId: 'company-4',
        title: 'Content Creator Intern',
        category: 'Content',
        location: 'Bandung',
        workType: 'onsite',
        durationMonths: 3,
        isPaid: false,
        description: 'Program magang Content Creator.',
        qualifications: [],
        benefits: [],
        createdAt: DateTime(2026, 10, 4),
        company: const Company(
          id: 'company-4',
          name: 'Ruangguru',
          industry: 'Pendidikan',
        ),
      ),
    ),
  ];

  @override
  Future<List<Application>> getMyApplications() async {
    return List.unmodifiable(_applications);
  }

  @override
  Future<Application> apply({
    required String jobId,
    required String cvDocumentId,
    String? coverLetterDocumentId,
    String? message,
  }) async {
    throw UnsupportedError(
      'Fitur apply tidak tersedia dalam preview.',
    );
  }

  @override
  Future<List<StatusHistory>> getHistory(
      String applicationId,
      ) async {
    return [];
  }

  @override
  Future<void> cancelApplication(String id) async {
    final index = _applications.indexWhere(
          (application) => application.id == id,
    );

    if (index == -1) {
      throw Exception('Lamaran tidak ditemukan.');
    }

    final old = _applications[index];

    _applications[index] = Application(
      id: old.id,
      jobId: old.jobId,
      job: old.job,
      studentId: old.studentId,
      student: old.student,
      cvDocumentId: old.cvDocumentId,
      khsDocumentId: old.khsDocumentId,
      coverLetterDocumentId: old.coverLetterDocumentId,
      message: old.message,
      status: 'cancelled',
      companyNote: old.companyNote,
      createdAt: old.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
