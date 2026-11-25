
class StatusHistory {
  final String id;
  final String applicationId;
  final String status;
  final DateTime changedAt;

  const StatusHistory({
    required this.id,
    required this.applicationId,
    required this.status,
    required this.changedAt,
  });

  factory StatusHistory.fromJson(Map<String, dynamic> json) {
    return StatusHistory(
      id: json['id'] as String,
      applicationId: json['application_id'] as String,
      status: json['status'] as String,
      changedAt: DateTime.parse(json['changed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'application_id': applicationId,
      'status': status,
      'changed_at': changedAt.toIso8601String(),
    };
  }
}
