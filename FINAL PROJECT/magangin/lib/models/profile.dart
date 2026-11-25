
class Profile {
  final String id;
  final String role;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? university;
  final String? major;
  final int? semester;
  final String? bio;
  final String verificationStatus;
  final String? verificationNote;

  const Profile({
    required this.id,
    required this.role,
    required this.fullName,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.university,
    this.major,
    this.semester,
    this.bio,
    this.verificationStatus = 'none',
    this.verificationNote,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      role: json['role'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      university: json['university'] as String?,
      major: json['major'] as String?,
      semester: (json['semester'] as num?)?.toInt(),
      bio: json['bio'] as String?,
      verificationStatus:
      json['verification_status'] as String? ?? 'none',
      verificationNote: json['verification_note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'university': university,
      'major': major,
      'semester': semester,
      'bio': bio,
      'verification_status': verificationStatus,
      'verification_note': verificationNote,
    };
  }
}
