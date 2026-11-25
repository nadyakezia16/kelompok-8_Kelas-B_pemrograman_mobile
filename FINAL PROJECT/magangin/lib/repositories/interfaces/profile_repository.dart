
import 'dart:io';

import '../../models/profile.dart';

abstract class ProfileRepository {
  Future<Profile?> getProfile(String id);

  Future<Profile> updateProfile(Profile profile);

  Future<String> uploadAvatar(File file);
}
