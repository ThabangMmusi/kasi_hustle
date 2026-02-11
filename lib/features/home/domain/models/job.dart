class Job {
  final String id;
  final String title;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final double budget;
  final String createdBy;
  final DateTime createdAt;
  final String status;
  final List<String> imageUrls;
  final List<String> requiredSkills;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.budget,
    required this.createdBy,
    required this.createdAt,
    required this.status,
    this.imageUrls = const [],
    this.requiredSkills = const [],
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      budget: json['budget']?.toDouble() ?? 0.0,
      createdBy: json['created_by'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      status: json['status'] ?? 'open',
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'])
          : [],
      requiredSkills: json['required_skills'] != null
          ? List<String>.from(json['required_skills'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'budget': budget,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'status': status,
      'image_urls': imageUrls,
      'required_skills': requiredSkills,
    };
  }
}
