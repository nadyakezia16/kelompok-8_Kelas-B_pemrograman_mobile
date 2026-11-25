
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase/supabase_config.dart';
import '../../models/company.dart';
import '../../models/job.dart';
import '../interfaces/job_repository.dart';

class SupabaseJobRepository implements JobRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  static const String _jobSelect = '*, company:companies(*)';

  @override
  Future<List<Job>> searchJobs({
    String? query,
    String? category,
    String? location,
    String? workType,
    int? durationMonths,
    bool? isPaid,
  }) async {
    var request = _client
        .from('jobs')
        .select(_jobSelect)
        .eq('status', 'open');

    if (query != null && query.trim().isNotEmpty) {
      request = request.ilike('title', '%${query.trim()}%');
    }

    if (category != null && category.isNotEmpty) {
      request = request.eq('category', category);
    }

    if (location != null && location.isNotEmpty) {
      request = request.ilike('location', '%$location%');
    }

    if (workType != null && workType.isNotEmpty) {
      request = request.eq('work_type', workType);
    }

    if (durationMonths != null) {
      request = request.eq('duration_months', durationMonths);
    }

    if (isPaid != null) {
      request = request.eq('is_paid', isPaid);
    }

    final response = await request.order(
      'created_at',
      ascending: false,
    );

    return (response as List)
        .map((item) => Job.fromJson(item))
        .toList();
  }

  @override
  Future<List<Job>> getLatestJobs() async {
    final response = await _client
        .from('jobs')
        .select(_jobSelect)
        .eq('status', 'open')
        .order('created_at', ascending: false)
        .limit(20);

    return (response as List)
        .map((item) => Job.fromJson(item))
        .toList();
  }

  @override
  Future<List<Job>> getRecommendedJobs() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      return getLatestJobs();
    }

    final preference = await _client
        .from('preferences')
        .select()
        .eq('student_id', user.id)
        .maybeSingle();

    final jobs = await getLatestJobs();

    if (preference == null) {
      return jobs;
    }

    final categories = List<String>.from(
      preference['categories'] ?? [],
    );
    final locations = List<String>.from(
      preference['locations'] ?? [],
    );
    final workTypes = List<String>.from(
      preference['work_types'] ?? [],
    );
    final duration = preference['duration_months'];

    int score(Job job) {
      var result = 0;

      if (categories.contains(job.category)) {
        result += 3;
      }

      if (locations.any(
            (location) =>
            job.location.toLowerCase().contains(location.toLowerCase()),
      )) {
        result += 2;
      }

      if (workTypes.contains(job.workType)) {
        result += 2;
      }

      if (duration != null && job.durationMonths == duration) {
        result += 1;
      }

      return result;
    }

    jobs.sort((a, b) => score(b).compareTo(score(a)));

    return jobs;
  }

  @override
  Future<Job?> getJob(String id) async {
    final response = await _client
        .from('jobs')
        .select(_jobSelect)
        .eq('id', id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Job.fromJson(response);
  }

  @override
  Future<Company?> getCompany(String id) async {
    final response = await _client
        .from('companies')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Company.fromJson(response);
  }

  @override
  Future<List<Job>> getJobsByCompany(String companyId) async {
    final response = await _client
        .from('jobs')
        .select(_jobSelect)
        .eq('company_id', companyId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => Job.fromJson(item))
        .toList();
  }
}
