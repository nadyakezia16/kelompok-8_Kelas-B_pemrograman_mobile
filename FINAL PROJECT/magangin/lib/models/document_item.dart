
class DocumentItem {
  final String id;
  final String ownerId;
  final String type;
  final String name;
  final String filePath;
  final DateTime createdAt;

  const DocumentItem({
    required this.id,
    required this.ownerId,
    required this.type,
    required this.name,
    required this.filePath,
    required this.createdAt,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      filePath: json['file_path'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'type': type,
      'name': name,
      'file_path': filePath,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
