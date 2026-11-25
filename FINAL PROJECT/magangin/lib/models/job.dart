
import 'company.dart';

class Job {
  final String id;
  final String companyId;
  final Company? company;
  final String title;
  final String category;
  final String location;
  final String workType;
  final int durationMonths;
  final bool isPaid;
  final double? allowance;
  final String description;
  final List<String> qualifications;
  final List<String> benefits;
  final DateTime? deadline;
  final String status;
  final DateTime createdAt;

  const Job({
    required this.id,
    required this.companyId,
    this.company,
    required this.title,
    required this.category,
    required this.location,
    required this.workType,
    required this.durationMonths,
    required this.isPaid,
    this.allowance,
    required this.description,
    required this.qualifications,
    required this.benefits,
    this.deadline,
    this.status = 'open',
    required this.createdAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      company: json['company'] == null
          ? null
          : Company.fromJson(
        json['company'] as Map<String, dynamic>,
      ),
      title: json['title'] as String,
      category: json['category'] as String,
      location: json['location'] as String,
      workType: json['work_type'] as String,
      durationMonths: (json['duration_months'] as num).toInt(),
      isPaid: json['is_paid'] as bool,
      allowance: (json['allowance'] as num?)?.toDouble(),
      description: json['description'] as String,
      qualifications: List<String>.from(
        json['qualifications'] as List? ?? [],
      ),
      benefits: List<String>.from(
        json['benefits'] as List? ?? [],
      ),
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      status: json['status'] as String? ?? 'open',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'company': company?.toJson(),
      'title': title,
      'category': category,
      'location': location,
      'work_type': workType,
      'duration_months': durationMonths,
      'is_paid': isPaid,
      'allowance': allowance,
      'description': description,
      'qualifications': qualifications,
      'benefits': benefits,
      'deadline': deadline?.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
