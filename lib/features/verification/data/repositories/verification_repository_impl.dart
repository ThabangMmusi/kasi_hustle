import 'dart:io';
import '../../domain/entities/verification_document.dart';
import '../../domain/repositories/verification_repository.dart';
import '../datasources/verification_data_source.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  final VerificationDataSource dataSource;

  VerificationRepositoryImpl(this.dataSource);

  @override
  Future<VerificationDocument> submitVerification({
    required String userId,
    required File selfieImage,
    required File idImage,
  }) async {
    try {
      // Upload images to storage
      final selfieUrl = await dataSource.uploadImage(
        image: selfieImage,
        userId: userId,
        imageType: 'selfie',
      );

      final idDocumentUrl = await dataSource.uploadImage(
        image: idImage,
        userId: userId,
        imageType: 'id_document',
      );

      // Submit verification with URLs
      final document = await dataSource.submitVerification(
        userId: userId,
        selfieUrl: selfieUrl,
        idDocumentUrl: idDocumentUrl,
      );

      return document;
    } catch (e) {
      throw Exception('Failed to submit verification: $e');
    }
  }

  @override
  Future<VerificationDocument?> getVerificationStatus(String userId) async {
    try {
      return await dataSource.getVerificationStatus(userId);
    } catch (e) {
      throw Exception('Failed to get verification status: $e');
    }
  }

  @override
  Future<String> uploadImage({
    required File image,
    required String userId,
    required String imageType,
  }) async {
    try {
      return await dataSource.uploadImage(
        image: image,
        userId: userId,
        imageType: imageType,
      );
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
