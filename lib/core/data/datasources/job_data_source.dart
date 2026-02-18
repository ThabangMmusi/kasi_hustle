import 'dart:convert';
import 'package:kasi_hustle/features/home/domain/models/job.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';
import 'package:kasi_hustle/core/services/user_profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Shared data source for job-related data across all features
/// This eliminates redundancy by centralizing job data management
abstract class JobDataSource {
  Future<List<Job>> getAllJobs({int page = 0, int limit = 10});
  Future<List<Job>> getJobsByUser(String userId);
  Future<List<Job>> searchJobs(String query);
  Future<UserProfile> getUserProfile();
  Future<void> applyForJob(String jobId, String userId);
}

class JobDataSourceImpl implements JobDataSource {
  final SupabaseClient _supabaseClient;
  static const String _jobsCacheKey = 'cached_jobs_list';

  JobDataSourceImpl(this._supabaseClient);

  @override
  Future<List<Job>> getAllJobs({int page = 0, int limit = 10}) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      // 1. Calculate range for pagination
      final from = page * limit;
      final to = from + limit - 1;

      // 2. Try to fetch from network with pagination
      final response = await _supabaseClient
          .from('jobs')
          .select()
          .order('created_at', ascending: false)
          .range(from, to);

      final jobs = response.map((json) => Job.fromJson(json)).toList();

      // 3. Cache first page only (top 20 jobs) to keep startup fast
      if (page == 0) {
        final jobsToCache = jobs.take(20).toList();
        final jobsJson = jobsToCache.map((job) => job.toJson()).toList();
        await prefs.setString(_jobsCacheKey, jsonEncode(jobsJson));
      }

      return jobs;
    } catch (e) {
      // 3. Fallback to cache
      final cachedString = prefs.getString(_jobsCacheKey);
      if (cachedString != null) {
        final List<dynamic> jsonList = jsonDecode(cachedString);
        return jsonList.map((json) => Job.fromJson(json)).toList();
      }
      rethrow;
    }
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

  @override
  Future<void> applyForJob(String jobId, String userId) async {
    try {
      await _supabaseClient.from('applications').insert({
        'job_id': jobId,
        'user_id': userId,
        'status': 'pending',
        'applied_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to submit application: $e');
    }
  }
}
