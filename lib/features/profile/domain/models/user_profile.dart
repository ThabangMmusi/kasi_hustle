class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final List<String> skills;
  final String? bio;
  final String? profileImage;
  final double rating;
  final int totalReviews;
  final bool isVerified;
  final String userType; // 'hustler' or 'job_provider'
  final DateTime createdAt;
  final int completedJobs;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.skills,
    this.bio,
    this.profileImage,
    required this.rating,
    required this.totalReviews,
    required this.isVerified,
    required this.userType,
    required this.createdAt,
    required this.completedJobs,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      skills: List<String>.from(json['skills'] ?? []),
      bio: json['bio'],
      profileImage: json['profile_image'],
      rating: json['rating']?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
      isVerified: json['is_verified'] ?? false,
      userType: json['user_type'] ?? 'hustler',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      completedJobs: json['completed_jobs'] ?? 0,
    );
  }

  UserProfile copyWith({
    String? name,
    String? phone,
    List<String>? skills,
    String? bio,
    String? profileImage,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      skills: skills ?? this.skills,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      rating: rating,
      totalReviews: totalReviews,
      isVerified: isVerified,
      userType: userType,
      createdAt: createdAt,
      completedJobs: completedJobs,
    );
  }
}
