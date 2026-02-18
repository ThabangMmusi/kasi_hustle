import 'package:kasi_hustle/core/data/datasources/job_data_source.dart';
import 'package:kasi_hustle/features/home/domain/models/job.dart';
import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Home feature data source
/// Delegates to shared JobDataSource for data operations
abstract class HomeLocalDataSource {
  Future<UserProfile> getUserProfile();
  Future<List<Job>> getJobs({int page = 0, int limit = 10});
  Future<void> applyForJob(String jobId, String userId);
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final JobDataSource jobDataSource;

  HomeLocalDataSourceImpl(this.jobDataSource);

  @override
  Future<UserProfile> getUserProfile() async {
    return await jobDataSource.getUserProfile();
  }

  @override
  Future<void> applyForJob(String jobId, String userId) async {
    return await jobDataSource.applyForJob(jobId, userId);
  }

  @override
  Future<List<Job>> getJobs({int page = 0, int limit = 10}) async {
    try {
      final supabaseClient = Supabase.instance.client;
      final currentUserId = supabaseClient.auth.currentUser?.id;

      if (currentUserId == null) {
        // If no user logged in, return all jobs
        return await jobDataSource.getAllJobs(page: page, limit: limit);
      }

      // Get all jobs
      final allJobs = await jobDataSource.getAllJobs(page: page, limit: limit);

      // Get jobs the current user has already applied to
      final applicationsData = await supabaseClient
          .from('applications')
          .select('job_id')
          .eq('user_id', currentUserId);

      final appliedJobIds = (applicationsData as List)
          .map((app) => app['job_id'] as String)
          .toSet();

      // Filter out jobs the user has already applied to
      return allJobs.where((job) => !appliedJobIds.contains(job.id)).toList();
    } catch (e) {
      // If query fails, return all jobs
      return await jobDataSource.getAllJobs(page: page, limit: limit);
    }
  }
}
