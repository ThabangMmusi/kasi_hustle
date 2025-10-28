import 'package:equatable/equatable.dart';

class Application extends Equatable {
  final String id;
  final String jobId;
  final String userId;
  final String coverLetter;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime? updatedAt;

  const Application({
    required this.id,
    required this.jobId,
    required this.userId,
    required this.coverLetter,
    required this.status,
    required this.appliedAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    jobId,
    userId,
    coverLetter,
    status,
    appliedAt,
    updatedAt,
  ];
}

enum ApplicationStatus { pending, accepted, rejected, withdrawn }
