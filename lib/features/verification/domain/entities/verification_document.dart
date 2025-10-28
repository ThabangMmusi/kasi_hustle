import 'package:equatable/equatable.dart';

class VerificationDocument extends Equatable {
  final String id;
  final String userId;
  final String selfieUrl;
  final String idDocumentUrl;
  final VerificationStatus status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? rejectionReason;

  const VerificationDocument({
    required this.id,
    required this.userId,
    required this.selfieUrl,
    required this.idDocumentUrl,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.rejectionReason,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    selfieUrl,
    idDocumentUrl,
    status,
    submittedAt,
    reviewedAt,
    rejectionReason,
  ];
}

enum VerificationStatus { pending, approved, rejected }
