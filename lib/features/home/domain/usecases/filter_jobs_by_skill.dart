import 'package:kasi_hustle/features/home/domain/models/job.dart';
import 'package:kasi_hustle/features/home/domain/repositories/home_repository.dart';

typedef FilterJobsBySkill = List<Job> Function(List<Job> jobs, String skill);

FilterJobsBySkill makeFilterJobsBySkill(HomeRepository repository) {
  return (jobs, skill) => repository.filterJobsBySkill(jobs, skill);
}
