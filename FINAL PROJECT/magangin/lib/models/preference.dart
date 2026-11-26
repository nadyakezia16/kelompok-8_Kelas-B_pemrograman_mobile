
class Preference {
  final String studentId;
  final List<String> categories;
  final List<String> locations;
  final List<String> workTypes;
  final int? durationMonths;

  const Preference({
    required this.studentId,
    this.categories = const [],
    this.locations = const [],
    this.workTypes = const [],
    this.durationMonths,
  });

  factory Preference.fromJson(Map<String, dynamic> json) {
    return Preference(
      studentId: json['student_id'] as String,
      categories: List<String>.from(
        json['categories'] as List? ?? [],
      ),
      locations: List<String>.from(
        json['locations'] as List? ?? [],
      ),
      workTypes: List<String>.from(
        json['work_types'] as List? ?? [],
      ),
      durationMonths: (json['duration_months'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'categories': categories,
      'locations': locations,
      'work_types': workTypes,
      'duration_months': durationMonths,
    };
  }
}
