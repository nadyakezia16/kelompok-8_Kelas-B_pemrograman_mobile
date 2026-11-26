
import '../interfaces/saved_job_repository.dart';

class MockSavedJobRepository implements SavedJobRepository {
  final List<String> _savedJobIds = [
    'job-001',
    'job-007',
  ];

  @override
  Future<List<String>> getSavedJobs() async {
    return List.unmodifiable(_savedJobIds);
  }

  @override
  Future<void> toggleSave(String jobId) async {
    if (_savedJobIds.contains(jobId)) {
      _savedJobIds.remove(jobId);
    } else {
      _savedJobIds.add(jobId);
    }
  }

  @override
  Future<bool> isSaved(String jobId) async {
    return _savedJobIds.contains(jobId);
  }
}
