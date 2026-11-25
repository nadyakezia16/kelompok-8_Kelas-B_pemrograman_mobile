
import '../../models/profile.dart';

abstract class AuthRepository {
  Future<Profile> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  });

  Future<Profile> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<Profile?> currentProfile();
}
