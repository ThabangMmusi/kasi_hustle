class UserProfile {
  final String id;
  final String firstName;
  final String lastName;

  final List<String> primarySkills;
  final List<String> secondarySkills;
  final String? bio;
  final String? profileImage;
  final double rating;
  final int totalReviews;
  final bool isVerified;
  final String userType; // 'hustler' or 'job_provider'
  final DateTime createdAt;
  final int completedJobs;
  final String? email;
  final String? phoneNumber;
  final String? locationName;
  final double? latitude;
  final double? longitude;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phoneNumber,
    this.primarySkills = const [],
    this.secondarySkills = const [],
    this.bio,
    this.profileImage,
    required this.rating,
    required this.totalReviews,
    required this.isVerified,
    required this.userType,
    required this.createdAt,
    required this.completedJobs,
    this.locationName,
    this.latitude,
    this.longitude,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email:
          json['email'], // Email might not be in DB profile, but useful if we merge it
      phoneNumber: json['phone_number'],
      primarySkills: List<String>.from(json['primary_skills'] ?? []),
      secondarySkills: List<String>.from(json['secondary_skills'] ?? []),
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
      locationName: json['location_name'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      // 'email': email, // Don't save email to profiles table if it's auth-only, but keeping it in model
      'phone_number': phoneNumber,
      'primary_skills': primarySkills,
      'secondary_skills': secondarySkills,
      'bio': bio,
      'profile_image': profileImage,
      'rating': rating,
      'total_reviews': totalReviews,
      'is_verified': isVerified,
      'user_type': userType,
      'created_at': createdAt.toIso8601String(),
      'completed_jobs': completedJobs,
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    List<String>? primarySkills,
    List<String>? secondarySkills,
    String? bio,
    String? profileImage,
    String? locationName,
    double? latitude,
    double? longitude,
  }) {
    return UserProfile(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      primarySkills: primarySkills ?? this.primarySkills,
      secondarySkills: secondarySkills ?? this.secondarySkills,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      rating: rating,
      totalReviews: totalReviews,
      isVerified: isVerified,
      userType: userType,
      createdAt: createdAt,
      completedJobs: completedJobs,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
