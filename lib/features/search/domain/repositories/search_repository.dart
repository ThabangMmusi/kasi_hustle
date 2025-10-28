import 'package:kasi_hustle/features/home/domain/models/job.dart';

abstract class SearchRepository {
  Future<List<Job>> searchJobs(String query);
}
