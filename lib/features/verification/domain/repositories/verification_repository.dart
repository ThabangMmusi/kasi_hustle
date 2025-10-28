import 'dart:io';
import '../entities/verification_document.dart';

abstract class VerificationRepository {
  /// Submit verification documents (selfie and ID)
  Future<VerificationDocument> submitVerification({
    required String userId,
    required File selfieImage,
    required File idImage,
  });

  /// Get verification status for a user
  Future<VerificationDocument?> getVerificationStatus(String userId);

  /// Upload image to storage and get URL
  Future<String> uploadImage({
    required File image,
    required String userId,
    required String imageType, // 'selfie' or 'id_document'
  });
}
