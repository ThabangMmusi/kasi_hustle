import '../models/application.dart';
import '../repositories/application_repository.dart';

class GetMyApplicationsUseCase {
  final ApplicationRepository repository;

  GetMyApplicationsUseCase(this.repository);

  Future<List<Application>> call(String userId) async {
    return await repository.getMyApplications(userId);
  }
}

class GetReceivedApplicationsUseCase {
  final ApplicationRepository repository;

  GetReceivedApplicationsUseCase(this.repository);

  Future<List<Application>> call(String userId) async {
    return await repository.getReceivedApplications(userId);
  }
}

class WithdrawApplicationUseCase {
  final ApplicationRepository repository;

  WithdrawApplicationUseCase(this.repository);

  Future<void> call(String applicationId) async {
    return await repository.withdrawApplication(applicationId);
  }
}

class UpdateApplicationStatusUseCase {
  final ApplicationRepository repository;

  UpdateApplicationStatusUseCase(this.repository);

  Future<void> call(String applicationId, String status) async {
    return await repository.updateApplicationStatus(applicationId, status);
  }
}
