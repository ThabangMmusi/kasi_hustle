import 'package:kasi_hustle/features/home/domain/models/job.dart';

abstract class BusinessHomeRepository {
  Future<List<Job>> getPostedJobs();
}
