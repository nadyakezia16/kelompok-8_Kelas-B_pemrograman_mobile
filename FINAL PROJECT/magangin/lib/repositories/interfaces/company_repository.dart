import '../../models/application.dart';
import '../../models/company.dart';
import '../../models/job.dart';

abstract class CompanyRepository {
  Future<Company?> getMyCompany();

  Future<Company> updateCompany(Company company);

  Future<List<Job>> getMyJobs();

  Future<Job> createJob(Job job);

  Future<Job> updateJob(Job job);

  Future<void> closeJob(String id);

  Future<void> deleteJob(String id);

  Future<List<Application>> getApplicants(String jobId);

  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? note,
  });

  Future<Map<String, dynamic>> getDashboardStats();
}