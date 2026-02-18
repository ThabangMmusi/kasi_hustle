import 'package:kasi_hustle/features/home/domain/models/job.dart';
import 'package:kasi_hustle/features/home/domain/repositories/home_repository.dart';

typedef GetJobs = Future<List<Job>> Function({int page, int limit});

GetJobs makeGetJobs(HomeRepository repository) {
  return ({int page = 0, int limit = 10}) =>
      repository.getJobs(page: page, limit: limit);
}
