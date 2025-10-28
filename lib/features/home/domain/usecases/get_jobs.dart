import 'package:kasi_hustle/features/home/domain/models/job.dart';
import 'package:kasi_hustle/features/home/domain/repositories/home_repository.dart';

typedef GetJobs = Future<List<Job>> Function();

GetJobs makeGetJobs(HomeRepository repository) {
  return () => repository.getJobs();
}
