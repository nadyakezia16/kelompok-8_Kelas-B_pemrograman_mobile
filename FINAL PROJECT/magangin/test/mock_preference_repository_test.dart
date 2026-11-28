import 'package:flutter_test/flutter_test.dart';

import 'package:magangin/models/preference.dart';
import 'package:magangin/repositories/mock/mock_preference_repository.dart';

void main() {
  group('MockPreferenceRepository', () {
    late MockPreferenceRepository repository;

    setUp(() {
      repository = MockPreferenceRepository();
    });

    test('Mengambil preferensi awal mahasiswa', () async {
      final preference = await repository.getPreferences();

      expect(preference, isNotNull);
      expect(preference!.studentId, 'student-001');
      expect(
        preference.categories,
        contains('Software Development'),
      );
      expect(preference.locations, contains('Makassar'));
      expect(preference.workTypes, contains('remote'));
      expect(preference.durationMonths, 3);
    });

    test('Menyimpan dan mengambil kembali preferensi mahasiswa', () async {
      const newPreference = Preference(
        studentId: 'student-001',
        categories: [
          'UI/UX Design',
          'Software Development',
        ],
        locations: [
          'Makassar',
          'Bandung',
        ],
        workTypes: [
          'remote',
          'onsite',
        ],
        durationMonths: 6,
      );

      final savedPreference = await repository.savePreferences(
        newPreference,
      );

      final retrievedPreference = await repository.getPreferences();

      expect(savedPreference.studentId, 'student-001');
      expect(retrievedPreference, isNotNull);
      expect(retrievedPreference!.categories, newPreference.categories);
      expect(retrievedPreference.locations, newPreference.locations);
      expect(retrievedPreference.workTypes, newPreference.workTypes);
      expect(
        retrievedPreference.durationMonths,
        newPreference.durationMonths,
      );
    });
  });
}
