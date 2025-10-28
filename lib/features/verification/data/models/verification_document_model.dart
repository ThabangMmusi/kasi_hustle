import '../../domain/entities/verification_document.dart';

class VerificationDocumentModel extends VerificationDocument {
  const VerificationDocumentModel({
    required super.id,
    required super.userId,
    required super.selfieUrl,
    required super.idDocumentUrl,
    required super.status,
    required super.submittedAt,
    super.reviewedAt,
    super.rejectionReason,
  });

  factory VerificationDocumentModel.fromJson(Map<String, dynamic> json) {
    return VerificationDocumentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      selfieUrl: json['selfie_url'] as String,
      idDocumentUrl: json['id_document_url'] as String,
      status: _statusFromString(json['status'] as String),
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'selfie_url': selfieUrl,
      'id_document_url': idDocumentUrl,
      'status': _statusToString(status),
      'submitted_at': submittedAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
    };
  }

  static VerificationStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return VerificationStatus.pending;
      case 'approved':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.pending;
    }
  }

  static String _statusToString(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return 'pending';
      case VerificationStatus.approved:
        return 'approved';
      case VerificationStatus.rejected:
        return 'rejected';
    }
  }
}
