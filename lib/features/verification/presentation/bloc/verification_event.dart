import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class VerificationEvent extends Equatable {
  const VerificationEvent();

  @override
  List<Object?> get props => [];
}

class StartVerification extends VerificationEvent {}

class SelfieCaptured extends VerificationEvent {
  final File selfieImage;
  const SelfieCaptured(this.selfieImage);

  @override
  List<Object> get props => [selfieImage];
}

class IdCaptured extends VerificationEvent {
  final File idImage;
  const IdCaptured(this.idImage);

  @override
  List<Object> get props => [idImage];
}

class RetakeSelfie extends VerificationEvent {}

class RetakeId extends VerificationEvent {}

class SubmitVerification extends VerificationEvent {}

class GoToPreviousStep extends VerificationEvent {}
