import 'package:kasi_hustle/features/home/domain/models/job.dart';
import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';

abstract class HomeRepository {
  Future<UserProfile> getUserProfile();
  Future<List<Job>> getJobs();
  List<Job> getRecommendedJobs(List<Job> allJobs, List<String> userSkills);
  List<Job> searchJobs(List<Job> jobs, String query);
  List<Job> filterJobsBySkill(List<Job> jobs, String skill);
  Future<void> submitApplication({
    required String jobId,
    required String userId,
  });
}
