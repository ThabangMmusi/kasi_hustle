import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ==================== MODELS ====================

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

// ==================== BLOC EVENTS ====================

abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final String name;
  final String? phone;
  final List<String> skills;
  final String? bio;

  UpdateProfile({
    required this.name,
    this.phone,
    required this.skills,
    this.bio,
  });
}

class UploadProfileImage extends ProfileEvent {
  final String imagePath;
  UploadProfileImage(this.imagePath);
}

// ==================== BLOC STATES ====================

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  final bool isEditing;

  ProfileLoaded({required this.profile, this.isEditing = false});

  ProfileLoaded copyWith({UserProfile? profile, bool? isEditing}) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}

class ProfileUpdating extends ProfileState {
  final UserProfile profile;
  ProfileUpdating(this.profile);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

// ==================== BLOC ====================

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UploadProfileImage>(_onUploadProfileImage);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      // Simulate fetching from Supabase
      await Future.delayed(const Duration(seconds: 1));

      final profile = UserProfile(
        id: '1',
        name: 'Thabo Mkhize',
        email: 'thabo.mkhize@example.com',
        phone: '+27 82 456 7890',
        skills: ['Plumbing', 'Electrical', 'Carpentry'],
        bio:
            'Experienced handyman with 5+ years in the trade. Available for quick jobs around Soweto. Quality work guaranteed!',
        profileImage: null,
        rating: 4.7,
        totalReviews: 23,
        isVerified: true,
        userType: 'hustler',
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        completedJobs: 47,
      );

      emit(ProfileLoaded(profile: profile));
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(ProfileUpdating(currentState.profile));

      try {
        await Future.delayed(const Duration(seconds: 1));

        final updatedProfile = currentState.profile.copyWith(
          name: event.name,
          phone: event.phone,
          skills: event.skills,
          bio: event.bio,
        );

        emit(ProfileLoaded(profile: updatedProfile, isEditing: false));
      } catch (e) {
        emit(ProfileError('Failed to update profile: $e'));
      }
    }
  }

  Future<void> _onUploadProfileImage(
    UploadProfileImage event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(ProfileUpdating(currentState.profile));

      try {
        await Future.delayed(const Duration(seconds: 1));

        final updatedProfile = currentState.profile.copyWith(
          profileImage: event.imagePath,
        );

        emit(ProfileLoaded(profile: updatedProfile));
      } catch (e) {
        emit(ProfileError('Failed to upload image: $e'));
      }
    }
  }
}

// ==================== PROFILE SCREEN ====================

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(LoadProfile()),
      child: const ProfileScreenContent(),
    );
  }
}

class ProfileScreenContent extends StatelessWidget {
  const ProfileScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD700)),
            );
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(LoadProfile());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ProfileLoaded || state is ProfileUpdating) {
            final profile = state is ProfileLoaded
                ? state.profile
                : (state as ProfileUpdating).profile;
            final isUpdating = state is ProfileUpdating;

            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    // App Bar
                    SliverAppBar(
                      expandedHeight: 100,
                      floating: false,
                      pinned: true,
                      backgroundColor: Colors.black,
                      elevation: 0,
                      title: const Text(
                        'Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(
                            Icons.settings_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // Navigate to settings
                          },
                        ),
                      ],
                    ),

                    // Profile Content
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Profile Picture & Verified Badge
                          Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFD700),
                                      Color(0xFFFFA500),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFFFFD700),
                                    width: 3,
                                  ),
                                ),
                                child: profile.profileImage != null
                                    ? ClipOval(
                                        child: Image.network(
                                          profile.profileImage!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.black,
                                      ),
                              ),
                              if (profile.isVerified)
                                Positioned(
                                  bottom: 5,
                                  right: 5,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF00D26A),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    // Trigger image upload
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Upload image functionality',
                                        ),
                                        backgroundColor: Color(0xFFFFD700),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFD700),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.black,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Name & Verified Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                profile.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (profile.isVerified) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.verified,
                                  color: Color(0xFF00D26A),
                                  size: 24,
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 4),

                          // User Type Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFFFD700),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.construction,
                                  color: Color(0xFFFFD700),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  profile.userType == 'hustler'
                                      ? 'Hustler'
                                      : 'Job Provider',
                                  style: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Stats Row
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatCard(
                                  icon: Icons.star,
                                  value: profile.rating.toStringAsFixed(1),
                                  label: 'Rating',
                                ),
                                _buildStatCard(
                                  icon: Icons.rate_review,
                                  value: '${profile.totalReviews}',
                                  label: 'Reviews',
                                ),
                                _buildStatCard(
                                  icon: Icons.work,
                                  value: '${profile.completedJobs}',
                                  label: 'Jobs Done',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Contact Details Section
                          _buildSectionTitle('Contact Details'),
                          _buildInfoCard(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: profile.email,
                          ),
                          _buildInfoCard(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: profile.phone ?? 'Not provided',
                          ),

                          const SizedBox(height: 24),

                          // Bio Section
                          _buildSectionTitle('About Me'),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Text(
                                profile.bio ?? 'No bio added yet',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Skills Section
                          _buildSectionTitle('My Skills'),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: profile.skills.map((skill) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFFFD700,
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFFFFD700),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Color(0xFFFFD700),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        skill,
                                        style: const TextStyle(
                                          color: Color(0xFFFFD700),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Member Since
                          Text(
                            'Member since ${_formatDate(profile.createdAt)}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Edit Profile Button
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  _showEditProfileDialog(context, profile);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFD700),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),

                // Loading Overlay
                if (isUpdating)
                  Container(
                    color: Colors.black.withOpacity(0.7),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFD700),
                      ),
                    ),
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFFFD700), size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFFFD700), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _showEditProfileDialog(BuildContext context, UserProfile profile) {
    final nameController = TextEditingController(text: profile.name);
    final phoneController = TextEditingController(text: profile.phone);
    final bioController = TextEditingController(text: profile.bio);
    final selectedSkills = List<String>.from(profile.skills);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFFD700)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Phone',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFFD700)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFFD700)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProfileBloc>().add(
                UpdateProfile(
                  name: nameController.text,
                  phone: phoneController.text,
                  skills: selectedSkills,
                  bio: bioController.text,
                ),
              );
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
