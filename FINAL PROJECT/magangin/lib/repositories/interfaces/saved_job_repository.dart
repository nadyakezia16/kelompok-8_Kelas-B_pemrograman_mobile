abstract class SavedJobRepository {
  Future<List<String>> getSavedJobs();

  Future<void> toggleSave(String jobId);

  Future<bool> isSaved(String jobId);
}