import 'package:kasi_hustle/features/home/domain/models/job.dart';
import 'package:kasi_hustle/features/search/domain/repositories/search_repository.dart';

typedef SearchJobs = Future<List<Job>> Function(String query);

SearchJobs makeSearchJobs(SearchRepository repository) {
  return (query) => repository.searchJobs(query);
}
