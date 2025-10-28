import 'package:kasi_hustle/features/home/domain/models/job.dart';
import 'package:kasi_hustle/features/business_home/domain/repositories/business_home_repository.dart';

typedef GetPostedJobs = Future<List<Job>> Function();

GetPostedJobs makeGetPostedJobs(BusinessHomeRepository repository) {
  return () => repository.getPostedJobs();
}
