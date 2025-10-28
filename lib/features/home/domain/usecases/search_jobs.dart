import 'package:kasi_hustle/features/home/domain/models/job.dart';
import 'package:kasi_hustle/features/home/domain/repositories/home_repository.dart';

typedef SearchJobs = List<Job> Function(List<Job> jobs, String query);

SearchJobs makeSearchJobs(HomeRepository repository) {
  return (jobs, query) => repository.searchJobs(jobs, query);
}
