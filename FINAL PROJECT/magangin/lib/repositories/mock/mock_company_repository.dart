import '../../models/application.dart';
import '../../models/company.dart';
import '../../models/job.dart';
import '../../models/status_history.dart';
import '../interfaces/company_repository.dart';
import '../interfaces/auth_repository.dart';

class MockCompanyRepository implements CompanyRepository {
  MockCompanyRepository({
    required this.authRepository,
    List<Job>? sharedJobs,
    List<Application>? sharedApplications,
    List<StatusHistory>? sharedHistory,
  }) : _jobs = sharedJobs ?? [],
       _applications = sharedApplications ?? [],
       _history = sharedHistory ?? [];

  final AuthRepository authRepository;

  Company? _company = const Company(
    id: 'company-001',
    name: 'PT Teknologi Nusantara',
    description: 'Perusahaan teknologi simulasi Magangin.',
    location: 'Makassar',
    industry: 'Technology',
  );

  Future<Company> _requireMyCompany() async {
    final profile = await authRepository.currentProfile();

    if (profile == null) {
      throw Exception('Silakan login terlebih dahulu.');
    }

    if (profile.role != 'company') {
      throw Exception('Akses hanya untuk akun perusahaan.');
    }

    if (profile.id != 'company-001') {
      throw Exception('Profil perusahaan tidak ditemukan.');
    }

    final company = _company;

    if (company == null) {
      throw Exception('Profil perusahaan tidak ditemukan.');
    }

    return company;
  }

  // Menggunakan daftar lowongan bersama.
  final List<Job> _jobs;

  // Menggunakan daftar lamaran bersama.
  final List<Application> _applications;

  // Menggunakan daftar riwayat status bersama.
  final List<StatusHistory> _history;

  @override
  Future<Company?> getMyCompany() async {
    return _requireMyCompany();
  }

  @override
  Future<Company> updateCompany(Company company) async {
    final currentCompany = await _requireMyCompany();

    if (company.id != currentCompany.id) {
      throw Exception('Tidak dapat mengubah identitas perusahaan.');
    }

    final updatedCompany = Company(
      id: currentCompany.id,
      name: company.name,
      logoUrl: company.logoUrl,
      description: company.description,
      location: company.location,
      website: company.website,
      industry: company.industry,
    );

    _company = updatedCompany;

    return updatedCompany;
  }

  @override
  Future<List<Job>> getMyJobs() async {
    final company = await _requireMyCompany();

    return List.unmodifiable(
      _jobs.where((job) => job.companyId == company.id),
    );
  }

  @override
  Future<Job> createJob(Job job) async {
    final company = await _requireMyCompany();

    final isDuplicate = _jobs.any((item) => item.id == job.id);

    if (isDuplicate) {
      throw Exception('ID lowongan sudah digunakan.');
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
    final company = await _requireMyCompany();

    final index = _jobs.indexWhere(
      (item) => item.id == job.id && item.companyId == company.id,
    );

    if (index == -1) {
      throw Exception('Lowongan tidak ditemukan.');
    }

    final updatedJob = Job(
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

    _jobs[index] = updatedJob;

    return updatedJob;
  }

  @override
  Future<void> closeJob(String id) async {
    final company = await _requireMyCompany();

    final index = _jobs.indexWhere(
      (job) => job.id == id && job.companyId == company.id,
    );

    if (index == -1) {
      throw Exception('Lowongan tidak ditemukan.');
    }

    _jobs[index] = Job(
      id: _jobs[index].id,
      companyId: company.id,
      company: company,
      title: _jobs[index].title,
      category: _jobs[index].category,
      location: _jobs[index].location,
      workType: _jobs[index].workType,
      durationMonths: _jobs[index].durationMonths,
      isPaid: _jobs[index].isPaid,
      allowance: _jobs[index].allowance,
      description: _jobs[index].description,
      qualifications: _jobs[index].qualifications,
      benefits: _jobs[index].benefits,
      deadline: _jobs[index].deadline,
      status: 'closed',
      createdAt: _jobs[index].createdAt,
    );
  }

  @override
  Future<void> deleteJob(String id) async {
    final company = await _requireMyCompany();

    final index = _jobs.indexWhere(
      (job) => job.id == id && job.companyId == company.id,
    );

    if (index == -1) {
      throw Exception('Lowongan tidak ditemukan.');
    }

    _jobs.removeAt(index);
  }

  @override
  Future<List<Application>> getApplicants(String jobId) async {
    final company = await _requireMyCompany();

    final jobExists = _jobs.any(
      (job) => job.id == jobId && job.companyId == company.id,
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
    final company = await _requireMyCompany();

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

    final applicationIndex = _applications.indexWhere(
      (application) => application.id == applicationId,
    );

    if (applicationIndex == -1) {
      throw Exception('Lamaran tidak ditemukan.');
    }

    final application = _applications[applicationIndex];

    final jobExists = _jobs.any(
      (job) =>
          job.id == application.jobId && job.companyId == company.id,
    );

    if (!jobExists) {
      throw Exception('Anda tidak memiliki akses ke lamaran ini.');
    }

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
      status: status,
      companyNote: note ?? application.companyNote,
      createdAt: application.createdAt,
      updatedAt: DateTime.now(),
    );

    _applications[applicationIndex] = updatedApplication;

   _history.add(
      StatusHistory(
        id: 'history-${DateTime.now().microsecondsSinceEpoch}',
        applicationId: applicationId,
        status: status,
        changedAt: DateTime.now(),
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
