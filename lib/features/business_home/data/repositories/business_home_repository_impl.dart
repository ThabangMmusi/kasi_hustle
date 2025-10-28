import 'package:kasi_hustle/features/business_home/data/datasources/business_home_local_data_source.dart';
import 'package:kasi_hustle/features/business_home/domain/repositories/business_home_repository.dart';
import 'package:kasi_hustle/features/home/domain/models/job.dart';

class BusinessHomeRepositoryImpl implements BusinessHomeRepository {
  final BusinessHomeLocalDataSource localDataSource;

  BusinessHomeRepositoryImpl(this.localDataSource);

  @override
  Future<List<Job>> getPostedJobs() async {
    try {
      return await localDataSource.getPostedJobs();
    } catch (e) {
      // In real implementation, handle errors, logging, etc.
      rethrow;
    }
  }
}
