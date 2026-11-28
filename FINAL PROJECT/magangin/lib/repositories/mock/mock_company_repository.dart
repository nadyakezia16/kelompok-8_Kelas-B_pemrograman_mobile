import '../../models/application.dart';
import '../../models/company.dart';
import '../../models/job.dart';
import '../../models/status_history.dart';
import '../interfaces/company_repository.dart';

class MockCompanyRepository implements CompanyRepository {
  MockCompanyRepository({
    List<Job>? sharedJobs,
    List<Application>? sharedApplications,
    List<StatusHistory>? sharedHistory,
  }) : _jobs = sharedJobs ?? [],
       _applications = sharedApplications ?? [],
       _history = sharedHistory ?? [];

  Company? _company = const Company(
    id: 'company-001',
    name: 'PT Teknologi Nusantara',
    description: 'Perusahaan teknologi simulasi Magangin.',
    location: 'Makassar',
    industry: 'Technology',
  );

  // Menggunakan daftar lowongan bersama.
  final List<Job> _jobs;

  // Menggunakan daftar lamaran bersama.
  final List<Application> _applications;

  // Menggunakan daftar riwayat status bersama.
  final List<StatusHistory> _history;

  @override
  Future<Company?> getMyCompany() async {
    return _company;
  }

  @override
  Future<Company> updateCompany(Company company) async {
    _company = company;
    return company;
  }

  @override
  Future<List<Job>> getMyJobs() async {
    final company = _company;

    if (company == null) {
      return [];
    }

    return List.unmodifiable(_jobs.where((job) => job.companyId == company.id));
  }

  @override
  Future<Job> createJob(Job job) async {
    final company = _company;

    if (company == null) {
      throw Exception('Profil perusahaan tidak ditemukan.');
    }

    final newJob = Job(
      id: job.id,
      companyId: company.id,
      company: company,
      title: job.title,
      category: job.category,
      location: job.location,
      workType: job.workType,
      durationMonths: job.durationMonths,
      isPaid: job.isPaid,
      allowance: job.allowance,
      description: job.description,
      qualifications: job.qualifications,
      benefits: job.benefits,
      deadline: job.deadline,
      status: job.status,
      createdAt: job.createdAt,
    );

    _jobs.add(newJob);

    return newJob;
  }

  @override
  Future<Job> updateJob(Job job) async {
    final company = _company;

    final index = _jobs.indexWhere(
      (item) => item.id == job.id && item.companyId == company?.id,
    );

    if (index == -1) {
      throw Exception('Lowongan tidak ditemukan.');
    }

    _jobs[index] = job;

    return job;
  }

  @override
  Future<void> closeJob(String id) async {
    final company = _company;

    final index = _jobs.indexWhere(
      (job) => job.id == id && job.companyId == company?.id,
    );

    if (index == -1) {
      throw Exception('Lowongan tidak ditemukan.');
    }

    final oldJob = _jobs[index];

    _jobs[index] = Job(
      id: oldJob.id,
      companyId: oldJob.companyId,
      company: oldJob.company,
      title: oldJob.title,
      category: oldJob.category,
      location: oldJob.location,
      workType: oldJob.workType,
      durationMonths: oldJob.durationMonths,
      isPaid: oldJob.isPaid,
      allowance: oldJob.allowance,
      description: oldJob.description,
      qualifications: oldJob.qualifications,
      benefits: oldJob.benefits,
      deadline: oldJob.deadline,
      status: 'closed',
      createdAt: oldJob.createdAt,
    );
  }

  @override
  Future<void> deleteJob(String id) async {
    final company = _company;

    final index = _jobs.indexWhere(
      (job) => job.id == id && job.companyId == company?.id,
    );

    if (index == -1) {
      throw Exception('Lowongan tidak ditemukan.');
    }

    _jobs.removeAt(index);
  }

  @override
  Future<List<Application>> getApplicants(String jobId) async {
    final company = _company;

    final jobExists = _jobs.any(
      (job) => job.id == jobId && job.companyId == company?.id,
    );

    if (!jobExists) {
      throw Exception('Lowongan tidak ditemukan.');
    }

    return List.unmodifiable(
      _applications.where((application) => application.jobId == jobId),
    );
  }

  @override
  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? note,
  }) async {
    const allowedStatuses = [
      'viewed',
      'processing',
      'interview',
      'accepted',
      'rejected',
    ];

    if (!allowedStatuses.contains(status)) {
      throw Exception('Status lamaran tidak valid.');
    }

    final company = _company;

    final index = _applications.indexWhere(
      (application) =>
          application.id == applicationId &&
          _jobs.any(
            (job) =>
                job.id == application.jobId && job.companyId == company?.id,
          ),
    );

    if (index == -1) {
      throw Exception('Lamaran tidak ditemukan.');
    }

    final oldApplication = _applications[index];

    final now = DateTime.now();

    _applications[index] = Application(
      id: oldApplication.id,
      jobId: oldApplication.jobId,
      job: oldApplication.job,
      studentId: oldApplication.studentId,
      student: oldApplication.student,
      cvDocumentId: oldApplication.cvDocumentId,
      khsDocumentId: oldApplication.khsDocumentId,
      coverLetterDocumentId: oldApplication.coverLetterDocumentId,
      message: oldApplication.message,
      status: status,
      companyNote: note ?? oldApplication.companyNote,
      createdAt: oldApplication.createdAt,
      updatedAt: now,
    );

    // Mencatat perubahan status agar dapat dilihat mahasiswa.
    _history.add(
      StatusHistory(
        id: 'history-${now.microsecondsSinceEpoch}',
        applicationId: applicationId,
        status: status,
        changedAt: now,
      ),
    );
  }

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    final myJobs = await getMyJobs();

    final jobIds = myJobs.map((job) => job.id).toSet();

    final myApplicants = _applications
        .where((application) => jobIds.contains(application.jobId))
        .toList();

    return {
      'total_jobs': myJobs.length,
      'open_jobs': myJobs.where((job) => job.status == 'open').length,
      'closed_jobs': myJobs.where((job) => job.status == 'closed').length,
      'total_applicants': myApplicants.length,
    };
  }
}
