import 'package:kasi_hustle/core/data/datasources/job_data_source.dart';
import 'package:kasi_hustle/features/home/domain/models/job.dart';

/// Business Home feature data source
/// Delegates to shared JobDataSource for data operations
abstract class BusinessHomeLocalDataSource {
  Future<List<Job>> getPostedJobs();
}

class BusinessHomeLocalDataSourceImpl implements BusinessHomeLocalDataSource {
  final JobDataSource jobDataSource;

  BusinessHomeLocalDataSourceImpl(this.jobDataSource);

  @override
  Future<List<Job>> getPostedJobs() async {
    // Fetch jobs posted by current user (business)
    // In real implementation, get actual user ID from auth
    return await jobDataSource.getJobsByUser('me');
  }
}
