import 'dart:io';
import '../models/verification_document_model.dart';
import '../../domain/entities/verification_document.dart';

abstract class VerificationDataSource {
  Future<VerificationDocumentModel> submitVerification({
    required String userId,
    required String selfieUrl,
    required String idDocumentUrl,
  });

  Future<VerificationDocumentModel?> getVerificationStatus(String userId);

  Future<String> uploadImage({
    required File image,
    required String userId,
    required String imageType,
  });
}

class VerificationDataSourceImpl implements VerificationDataSource {
  // TODO: Replace with actual Supabase implementation
  // This is dummy implementation for now

  final Map<String, VerificationDocumentModel> _verificationDocuments = {};
  int _idCounter = 1;

  @override
  Future<VerificationDocumentModel> submitVerification({
    required String userId,
    required String selfieUrl,
    required String idDocumentUrl,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final document = VerificationDocumentModel(
      id: 'verification_${_idCounter++}',
      userId: userId,
      selfieUrl: selfieUrl,
      idDocumentUrl: idDocumentUrl,
      status: VerificationStatus.pending,
      submittedAt: DateTime.now(),
    );

    _verificationDocuments[userId] = document;

    // Simulate auto-approval after 3 seconds (for testing)
    Future.delayed(const Duration(seconds: 3), () {
      _verificationDocuments[userId] = VerificationDocumentModel(
        id: document.id,
        userId: document.userId,
        selfieUrl: document.selfieUrl,
        idDocumentUrl: document.idDocumentUrl,
        status: VerificationStatus.approved,
        submittedAt: document.submittedAt,
        reviewedAt: DateTime.now(),
      );
    });

    return document;
  }

  @override
  Future<VerificationDocumentModel?> getVerificationStatus(
    String userId,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return _verificationDocuments[userId];
  }

  @override
  Future<String> uploadImage({
    required File image,
    required String userId,
    required String imageType,
  }) async {
    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 1));

    // Return dummy URL (in production, this would upload to Supabase Storage)
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'https://storage.supabase.co/verification/$userId/${imageType}_$timestamp.jpg';
  }
}
