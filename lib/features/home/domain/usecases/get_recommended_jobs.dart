import 'package:kasi_hustle/features/home/domain/models/job.dart';
import 'package:kasi_hustle/features/home/domain/repositories/home_repository.dart';

typedef GetRecommendedJobs =
    List<Job> Function(List<Job> allJobs, List<String> userSkills);

GetRecommendedJobs makeGetRecommendedJobs(HomeRepository repository) {
  return (allJobs, userSkills) =>
      repository.getRecommendedJobs(allJobs, userSkills);
}
