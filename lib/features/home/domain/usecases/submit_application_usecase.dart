import '../repositories/home_repository.dart';

class SubmitApplicationUseCase {
  final HomeRepository repository;

  SubmitApplicationUseCase(this.repository);

  Future<void> call({required String jobId, required String userId}) async {
    return await repository.submitApplication(jobId: jobId, userId: userId);
  }
}
