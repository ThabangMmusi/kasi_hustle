import 'dart:io';
import '../entities/verification_document.dart';
import '../repositories/verification_repository.dart';

class SubmitVerificationUseCase {
  final VerificationRepository repository;

  SubmitVerificationUseCase(this.repository);

  Future<VerificationDocument> call({
    required String userId,
    required File selfieImage,
    required File idImage,
  }) async {
    return await repository.submitVerification(
      userId: userId,
      selfieImage: selfieImage,
      idImage: idImage,
    );
  }
}
