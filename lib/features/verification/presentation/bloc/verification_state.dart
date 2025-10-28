import 'package:equatable/equatable.dart';
import 'dart:io';

enum VerificationFlowStatus {
  initial,
  instructions,
  selfieCapture,
  selfiePreview,
  idCapture,
  idPreview,
  uploading,
  success,
  failure,
}

class VerificationState extends Equatable {
  final VerificationFlowStatus status;
  final File? selfieImage;
  final File? idImage;
  final String? errorMessage;

  const VerificationState({
    this.status = VerificationFlowStatus.initial,
    this.selfieImage,
    this.idImage,
    this.errorMessage,
  });

  VerificationState copyWith({
    VerificationFlowStatus? status,
    File? selfieImage,
    File? idImage,
    String? errorMessage,
  }) {
    return VerificationState(
      status: status ?? this.status,
      selfieImage: selfieImage ?? this.selfieImage,
      idImage: idImage ?? this.idImage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, selfieImage, idImage, errorMessage];
}
