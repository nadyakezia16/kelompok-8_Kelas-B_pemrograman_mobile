import '../../models/company.dart';
import '../../models/job.dart';

abstract class JobRepository {
  Future<List<Job>> searchJobs({
    String? query,
    String? category,
    String? location,
    String? workType,
    int? durationMonths,
    bool? isPaid,
  });

  Future<List<Job>> getLatestJobs();

  Future<List<Job>> getRecommendedJobs();

  Future<Job?> getJob(String id);

  Future<Company?> getCompany(String id);

  Future<List<Job>> getJobsByCompany(String companyId);
}