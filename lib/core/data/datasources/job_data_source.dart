import 'package:kasi_hustle/features/home/domain/models/job.dart';
import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';
import 'package:kasi_hustle/core/services/user_profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Shared data source for job-related data across all features
/// This eliminates redundancy by centralizing job data management
abstract class JobDataSource {
  Future<List<Job>> getAllJobs();
  Future<List<Job>> getJobsByUser(String userId);
  Future<List<Job>> searchJobs(String query);
  Future<UserProfile> getUserProfile();
}

class JobDataSourceImpl implements JobDataSource {
  final SupabaseClient _supabaseClient;

  JobDataSourceImpl(this._supabaseClient);
  @override
  Future<List<Job>> getAllJobs() async {
    final response = await _supabaseClient.from('jobs').select();
    return response.map((json) => Job.fromJson(json)).toList();
  }

  @override
  Future<List<Job>> getJobsByUser(String userId) async {
    final response = await _supabaseClient
        .from('jobs')
        .select()
        .eq('created_by', userId);
    return response.map((json) => Job.fromJson(json)).toList();
  }

  @override
  Future<List<Job>> searchJobs(String query) async {
    if (query.isEmpty) {
      return [];
    }
    final response = await _supabaseClient
        .from('jobs')
        .select()
        .or(
          'title.ilike.%$query%,description.ilike.%$query%,location.ilike.%$query%',
        );
    return response.map((json) => Job.fromJson(json)).toList();
  }

  @override
  Future<UserProfile> getUserProfile() async {
    // Simulate database/API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Get user from centralized service
    final currentUser = UserProfileService().currentUser;

    if (currentUser != null) {
      return currentUser;
    }

    // Fallback if no user is logged in (shouldn't happen in normal flow)
    return UserProfile(
      id: '1',
      firstName: 'Guest',
      lastName: 'User',
      primarySkills: [],
      userType: 'hustler',
      rating: 0.0,
      totalReviews: 0,
      isVerified: false,
      createdAt: DateTime.now(),
      completedJobs: 0,
    );
  }
}
