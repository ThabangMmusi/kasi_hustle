import 'package:kasi_hustle/features/home/data/datasources/home_local_data_source.dart';
import 'package:kasi_hustle/features/home/domain/models/job.dart';
import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';
import 'package:kasi_hustle/features/home/domain/repositories/home_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource localDataSource;

  HomeRepositoryImpl(this.localDataSource);

  @override
  Future<UserProfile> getUserProfile() async {
    try {
      return await localDataSource.getUserProfile();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Job>> getJobs() async {
    try {
      return await localDataSource.getJobs();
    } catch (e) {
      rethrow;
    }
  }

  @override
  List<Job> getRecommendedJobs(List<Job> allJobs, List<String> userSkills) {
    return allJobs.where((job) {
      return userSkills.any(
        (skill) =>
            job.title.toLowerCase().contains(skill.toLowerCase()) ||
            job.description.toLowerCase().contains(skill.toLowerCase()),
      );
    }).toList();
  }

  @override
  List<Job> searchJobs(List<Job> jobs, String query) {
    return jobs.where((job) {
      return job.title.toLowerCase().contains(query.toLowerCase()) ||
          job.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  @override
  List<Job> filterJobsBySkill(List<Job> jobs, String skill) {
    return jobs.where((job) {
      // Filter by required_skills field first (if available)
      if (job.requiredSkills.isNotEmpty) {
        return job.requiredSkills.any(
          (s) => s.toLowerCase().contains(skill.toLowerCase()),
        );
      }
      // Fallback to title/description matching if no skills set
      return job.title.toLowerCase().contains(skill.toLowerCase()) ||
          job.description.toLowerCase().contains(skill.toLowerCase());
    }).toList();
  }

  @override
  Future<void> submitApplication({
    required String jobId,
    required String userId,
  }) async {
    try {
      final supabaseClient = Supabase.instance.client;
      await supabaseClient.from('applications').insert({
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
