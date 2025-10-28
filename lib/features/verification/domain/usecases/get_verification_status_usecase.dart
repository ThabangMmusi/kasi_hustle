import '../entities/verification_document.dart';
import '../repositories/verification_repository.dart';

class GetVerificationStatusUseCase {
  final VerificationRepository repository;

  GetVerificationStatusUseCase(this.repository);

  Future<VerificationDocument?> call(String userId) async {
    return await repository.getVerificationStatus(userId);
  }
}
