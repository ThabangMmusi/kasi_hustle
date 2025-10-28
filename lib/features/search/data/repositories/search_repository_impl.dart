import 'package:kasi_hustle/features/home/domain/models/job.dart';
import 'package:kasi_hustle/features/search/data/datasources/search_local_data_source.dart';
import 'package:kasi_hustle/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchLocalDataSource localDataSource;

  SearchRepositoryImpl(this.localDataSource);

  @override
  Future<List<Job>> searchJobs(String query) async {
    try {
      return await localDataSource.searchJobs(query);
    } catch (e) {
      rethrow;
    }
  }
}
