import 'package:kasi_hustle/core/data/datasources/job_data_source.dart';
import 'package:kasi_hustle/features/home/domain/models/job.dart';

/// Search feature data source
/// Delegates to shared JobDataSource for data operations
abstract class SearchLocalDataSource {
  Future<List<Job>> searchJobs(String query);
}

class SearchLocalDataSourceImpl implements SearchLocalDataSource {
  final JobDataSource jobDataSource;

  SearchLocalDataSourceImpl(this.jobDataSource);

  @override
  Future<List<Job>> searchJobs(String query) async {
    return await jobDataSource.searchJobs(query);
  }
}
