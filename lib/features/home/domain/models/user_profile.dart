class UserProfile {
  final String id;
  final String name;
  final String email;
  final List<String> skills;
  final double rating;
  final int totalReviews;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.skills,
    required this.rating,
    required this.totalReviews,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'] ?? 'Hustler',
      email: json['email'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      rating: json['rating']?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
    );
  }
}
