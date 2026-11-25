
import '../../models/application.dart';
import '../../models/company.dart';
import '../../models/job.dart';
import '../interfaces/company_repository.dart';

class MockCompanyRepository implements CompanyRepository {
  Company? _company = const Company(
    id: 'company-001',
    name: 'PT Teknologi Nusantara',
    description: 'Perusahaan teknologi simulasi Magangin.',
    location: 'Makassar',
    industry: 'Technology',
  );

  final List<Job> _jobs = [];

  final List<Application> _applications = [];

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
    return List.unmodifiable(_jobs);
  }

  @override
  Future<Job> createJob(Job job) async {
    _jobs.add(job);
    return job;
  }

  @override
  Future<Job> updateJob(Job job) async {
    final index = _jobs.indexWhere(
          (item) => item.id == job.id,
    );

    if (index == -1) {
      throw Exception('Lowongan tidak ditemukan.');
    }

    _jobs[index] = job;
    return job;
  }

  @override
  Future<void> closeJob(String id) async {
    final index = _jobs.indexWhere(
          (job) => job.id == id,
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
    _jobs.removeWhere((job) => job.id == id);
  }

  @override
  Future<List<Application>> getApplicants(String jobId) async {
    return List.unmodifiable(
      _applications.where(
            (application) => application.jobId == jobId,
      ),
    );
  }

  @override
  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? note,
  }) async {
    final index = _applications.indexWhere(
          (application) => application.id == applicationId,
    );

    if (index == -1) {
      throw Exception('Lamaran tidak ditemukan.');
    }

    final oldApplication = _applications[index];

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
      companyNote: note,
      createdAt: oldApplication.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    return {
      'total_jobs': _jobs.length,
      'open_jobs': _jobs.where((job) => job.status == 'open').length,
      'closed_jobs': _jobs.where((job) => job.status == 'closed').length,
      'total_applicants': _applications.length,
    };
  }
}
