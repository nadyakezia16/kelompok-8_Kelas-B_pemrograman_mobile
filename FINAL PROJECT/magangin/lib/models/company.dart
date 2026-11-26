
class Company {
  final String id;
  final String name;
  final String? logoUrl;
  final String? description;
  final String? location;
  final String? website;
  final String? industry;

  const Company({
    required this.id,
    required this.name,
    this.logoUrl,
    this.description,
    this.location,
    this.website,
    this.industry,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String?,
      description: json['description'] as String?,
      location: json['location'] as String?,
      website: json['website'] as String?,
      industry: json['industry'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'description': description,
      'location': location,
      'website': website,
      'industry': industry,
    };
  }
}
