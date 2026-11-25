import '../../models/preference.dart';

abstract class PreferenceRepository {
  Future<Preference?> getPreferences();

  Future<Preference> savePreferences(Preference preference);
}