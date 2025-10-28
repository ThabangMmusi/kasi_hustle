import 'package:kasi_hustle/features/onboarding/domain/repositories/onboarding_repository.dart';

class RequestVerification {
  final OnboardingRepository repository;

  RequestVerification(this.repository);

  Future<void> call(String userId) {
    return repository.requestVerification(userId);
  }
}
