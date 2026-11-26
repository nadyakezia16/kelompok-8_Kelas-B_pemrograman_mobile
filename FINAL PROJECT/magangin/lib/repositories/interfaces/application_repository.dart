import '../../models/application.dart';
import '../../models/status_history.dart';

abstract class ApplicationRepository {
  Future<Application> apply({
    required String jobId,
    required String cvDocumentId,
    String? coverLetterDocumentId,
    String? message,
  });

  Future<List<Application>> getMyApplications();

  Future<List<StatusHistory>> getHistory(String applicationId);

  Future<void> cancelApplication(String id);
}
