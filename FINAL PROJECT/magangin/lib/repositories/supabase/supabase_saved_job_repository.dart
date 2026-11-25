
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase/supabase_config.dart';
import '../interfaces/saved_job_repository.dart';

class SupabaseSavedJobRepository implements SavedJobRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  String get _userId {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    return user.id;
  }

  @override
  Future<List<String>> getSavedJobs() async {
    final response = await _client
        .from('saved_jobs')
        .select('job_id')
        .eq('student_id', _userId);

    return (response as List)
        .map((item) => item['job_id'] as String)
        .toList();
  }

  @override
  Future<void> toggleSave(String jobId) async {
    final userId = _userId;

    final existing = await _client
        .from('saved_jobs')
        .select('job_id')
        .eq('student_id', userId)
        .eq('job_id', jobId)
        .maybeSingle();

    if (existing != null) {
      await _client
          .from('saved_jobs')
          .delete()
          .eq('student_id', userId)
          .eq('job_id', jobId);
    } else {
      await _client.from('saved_jobs').insert({
        'student_id': userId,
        'job_id': jobId,
      });
    }
  }

  @override
  Future<bool> isSaved(String jobId) async {
    final response = await _client
        .from('saved_jobs')
        .select('job_id')
        .eq('student_id', _userId)
        .eq('job_id', jobId)
        .maybeSingle();

    return response != null;
  }
}
