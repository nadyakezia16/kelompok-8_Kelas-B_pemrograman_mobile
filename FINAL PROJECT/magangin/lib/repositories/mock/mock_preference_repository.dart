
import '../../models/preference.dart';
import '../interfaces/preference_repository.dart';

class MockPreferenceRepository implements PreferenceRepository {
  Preference? _preferences = const Preference(
    studentId: 'student-001',
    categories: [
      'Software Development',
      'Mobile Development',
    ],
    locations: [
      'Makassar',
      'Jakarta',
    ],
    workTypes: [
      'remote',
      'hybrid',
    ],
    durationMonths: 3,
  );

  @override
  Future<Preference?> getPreferences() async {
    return _preferences;
  }

  @override
  Future<Preference> savePreferences(
      Preference preference,
      ) async {
    _preferences = preference;
    return preference;
  }
}
