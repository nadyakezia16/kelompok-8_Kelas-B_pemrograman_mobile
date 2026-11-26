import '../../models/profile.dart';

abstract class AdminRepository {
  Future<List<Profile>> getPendingVerifications();

  Future<void> approve(String studentId);

  Future<void> reject({
    required String studentId,
    required String reason,
  });
}