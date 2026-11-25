
import 'job.dart';
import 'profile.dart';

class Application {
  final String id;
  final String jobId;
  final Job? job;
  final String studentId;
  final Profile? student;
  final String? cvDocumentId;
  final String? khsDocumentId;
  final String? coverLetterDocumentId;
  final String? message;
  final String status;
  final String? companyNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Application({
    required this.id,
    required this.jobId,
    this.job,
    required this.studentId,
    this.student,
    this.cvDocumentId,
    this.khsDocumentId,
    this.coverLetterDocumentId,
    this.message,
    this.status = 'sent',
    this.companyNote,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'] as String,
      jobId: json['job_id'] as String,
      job: json['job'] == null
          ? null
          : Job.fromJson(json['job'] as Map<String, dynamic>),
      studentId: json['student_id'] as String,
      student: json['student'] == null
          ? null
          : Profile.fromJson(json['student'] as Map<String, dynamic>),
      cvDocumentId: json['cv_document_id'] as String?,
      khsDocumentId: json['khs_document_id'] as String?,
      coverLetterDocumentId:
      json['cover_letter_document_id'] as String?,
      message: json['message'] as String?,
      status: json['status'] as String? ?? 'sent',
      companyNote: json['company_note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'job': job?.toJson(),
      'student_id': studentId,
      'student': student?.toJson(),
      'cv_document_id': cvDocumentId,
      'khs_document_id': khsDocumentId,
      'cover_letter_document_id': coverLetterDocumentId,
      'message': message,
      'status': status,
      'company_note': companyNote,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
