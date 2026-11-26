
import '../../models/application.dart';
import '../../models/status_history.dart';
import '../interfaces/application_repository.dart';

class MockApplicationRepository implements ApplicationRepository {
  final List<Application> _applications = [];

  final List<StatusHistory> _history = [];

  @override
  Future<Application> apply({
    required String jobId,
    required String cvDocumentId,
    String? coverLetterDocumentId,
    String? message,
  }) async {
    // Memastikan mahasiswa sudah terverifikasi.
    const verificationStatus = 'verified';

    if (verificationStatus != 'verified') {
      throw Exception(
        'Akun mahasiswa harus terverifikasi sebelum melamar.',
      );
    }

    // Memeriksa apakah mahasiswa sudah pernah melamar.
    final alreadyApplied = _applications.any(
          (application) =>
      application.jobId == jobId &&
          application.studentId == 'student-001' &&
          application.status != 'cancelled',
    );

    if (alreadyApplied) {
      throw Exception('Kamu sudah pernah melamar lowongan ini.');
    }

    final now = DateTime.now();

    final application = Application(
      id: 'application-${now.microsecondsSinceEpoch}',
      jobId: jobId,
      studentId: 'student-001',
      cvDocumentId: cvDocumentId,
      coverLetterDocumentId: coverLetterDocumentId,
      message: message,
      status: 'sent',
      createdAt: now,
      updatedAt: now,
    );

    _applications.add(application);

    _history.add(
      StatusHistory(
        id: 'history-${now.microsecondsSinceEpoch}',
        applicationId: application.id,
        status: 'sent',
        changedAt: now,
      ),
    );

    return application;
  }

  @override
  Future<List<Application>> getMyApplications() async {
    return List.unmodifiable(
      _applications.where(
            (application) => application.studentId == 'student-001',
      ),
    );
  }

  @override
  Future<List<StatusHistory>> getHistory(
      String applicationId,
      ) async {
    return List.unmodifiable(
      _history.where(
            (item) => item.applicationId == applicationId,
      ),
    );
  }

  @override
  Future<void> cancelApplication(String id) async {
    final index = _applications.indexWhere(
          (application) => application.id == id,
    );

    if (index == -1) {
      throw Exception('Lamaran tidak ditemukan.');
    }

    final application = _applications[index];

    if (application.status != 'sent') {
      throw Exception(
        'Lamaran hanya dapat dibatalkan saat status masih sent.',
      );
    }

    final now = DateTime.now();

    final updatedApplication = Application(
      id: application.id,
      jobId: application.jobId,
      job: application.job,
      studentId: application.studentId,
      student: application.student,
      cvDocumentId: application.cvDocumentId,
      khsDocumentId: application.khsDocumentId,
      coverLetterDocumentId: application.coverLetterDocumentId,
      message: application.message,
      status: 'cancelled',
      companyNote: application.companyNote,
      createdAt: application.createdAt,
      updatedAt: now,
    );

    _applications[index] = updatedApplication;

    _history.add(
      StatusHistory(
        id: 'history-${now.microsecondsSinceEpoch}',
        applicationId: id,
        status: 'cancelled',
        changedAt: now,
      ),
    );
  }
}
