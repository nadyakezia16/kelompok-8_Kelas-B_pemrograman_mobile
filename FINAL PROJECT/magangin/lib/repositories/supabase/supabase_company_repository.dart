
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase/supabase_config.dart';
import '../../models/application.dart';
import '../../models/company.dart';
import '../../models/job.dart';
import '../interfaces/company_repository.dart';

class SupabaseCompanyRepository implements CompanyRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  String get _userId {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    return user.id;
  }

  static const String _jobSelect = '*, company:companies(*)';

  static const List<String> _allowedStatuses = [
    'viewed',
    'processing',
    'interview',
    'accepted',
    'rejected',
  ];

  Future<Company> _requireCompany() async {
    final response = await _client
        .from('companies')
        .select()
        .eq('user_id', _userId)
        .maybeSingle();

    if (response == null) {
      throw Exception('Profil perusahaan tidak ditemukan.');
    }

    return Company.fromJson(response);
  }

  @override
  Future<Company?> getMyCompany() async {
    final response = await _client
        .from('companies')
        .select()
        .eq('user_id', _userId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Company.fromJson(response);
  }

  @override
  Future<Company> updateCompany(Company company) async {
    final currentCompany = await _requireCompany();

    final data = Map<String, dynamic>.from(company.toJson())
      ..remove('id');

    final response = await _client
        .from('companies')
        .update(data)
        .eq('id', currentCompany.id)
        .select()
        .single();

    return Company.fromJson(response);
  }

  @override
  Future<List<Job>> getMyJobs() async {
    final company = await _requireCompany();

    final response = await _client
        .from('jobs')
        .select(_jobSelect)
        .eq('company_id', company.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => Job.fromJson(item))
        .toList();
  }

  @override
  Future<Job> createJob(Job job) async {
    final company = await _requireCompany();

    final data = Map<String, dynamic>.from(job.toJson())
      ..remove('id')
      ..remove('company')
      ..remove('created_at');

    data['company_id'] = company.id;
    data['status'] = 'open';

    final response = await _client
        .from('jobs')
        .insert(data)
        .select(_jobSelect)
        .single();

    return Job.fromJson(response);
  }

  @override
  Future<Job> updateJob(Job job) async {
    final company = await _requireCompany();

    final data = Map<String, dynamic>.from(job.toJson())
      ..remove('id')
      ..remove('company')
      ..remove('company_id')
      ..remove('created_at');

    final response = await _client
        .from('jobs')
        .update(data)
        .eq('id', job.id)
        .eq('company_id', company.id)
        .select(_jobSelect)
        .maybeSingle();

    if (response == null) {
      throw Exception(
        'Lowongan tidak ditemukan atau bukan milik perusahaanmu.',
      );
    }

    return Job.fromJson(response);
  }

  @override
  Future<void> closeJob(String id) async {
    final company = await _requireCompany();

    final response = await _client
        .from('jobs')
        .update({'status': 'closed'})
        .eq('id', id)
        .eq('company_id', company.id)
        .select('id')
        .maybeSingle();

    if (response == null) {
      throw Exception(
        'Lowongan tidak ditemukan atau bukan milik perusahaanmu.',
      );
    }
  }

  @override
  Future<void> deleteJob(String id) async {
    final company = await _requireCompany();

    final response = await _client
        .from('jobs')
        .delete()
        .eq('id', id)
        .eq('company_id', company.id)
        .select('id');

    if ((response as List).isEmpty) {
      throw Exception(
        'Lowongan tidak ditemukan atau bukan milik perusahaanmu.',
      );
    }
  }

  @override
  Future<List<Application>> getApplicants(String jobId) async {
    final company = await _requireCompany();

    // Pastikan lowongan memang milik perusahaan yang login.
    final job = await _client
        .from('jobs')
        .select('id')
        .eq('id', jobId)
        .eq('company_id', company.id)
        .maybeSingle();

    if (job == null) {
      throw Exception('Lowongan tidak ditemukan.');
    }

    final response = await _client
        .from('applications')
        .select(
      '*, job:jobs(*, company:companies(*)), '
          'student:profiles(*)',
    )
        .eq('job_id', jobId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => Application.fromJson(item))
        .toList();
  }

  @override
  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? note,
  }) async {
    final company = await _requireCompany();

    if (!_allowedStatuses.contains(status)) {
      throw Exception('Status lamaran tidak valid.');
    }

    // Pastikan lamaran berasal dari lowongan perusahaan ini.
    final application = await _client
        .from('applications')
        .select('id, job_id')
        .eq('id', applicationId)
        .maybeSingle();

    if (application == null) {
      throw Exception('Lamaran tidak ditemukan.');
    }

    final job = await _client
        .from('jobs')
        .select('id')
        .eq('id', application['job_id'])
        .eq('company_id', company.id)
        .maybeSingle();

    if (job == null) {
      throw Exception('Lamaran bukan milik perusahaanmu.');
    }

    await _client
        .from('applications')
        .update({
      'status': status,
      'company_note': note,
      'updated_at': DateTime.now().toIso8601String(),
    })
        .eq('id', applicationId);

    await _client.from('application_status_history').insert({
      'application_id': applicationId,
      'status': status,
    });
  }

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    final jobs = await getMyJobs();



    final jobIds = jobs.map((job) => job.id).toList();

    var applications = <dynamic>[];

    if (jobIds.isNotEmpty) {
      applications = await _client
          .from('applications')
          .select('id, status')
          .inFilter('job_id', jobIds);
    }

    return {
      'total_jobs': jobs.length,
      'open_jobs': jobs.where((job) => job.status == 'open').length,
      'closed_jobs': jobs.where((job) => job.status == 'closed').length,
      'total_applicants': applications.length,
    };
  }
}
