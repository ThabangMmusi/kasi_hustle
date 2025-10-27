import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// ==================== EVENTS ====================

abstract class VerificationEvent extends Equatable {
  const VerificationEvent();

  @override
  List<Object?> get props => [];
}

class GoToStep extends VerificationEvent {
  final int step;

  const GoToStep(this.step);

  @override
  List<Object> get props => [step];
}

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

class SubmitVerification extends VerificationEvent {}

// ==================== STATES ====================

abstract class VerificationState extends Equatable {
  final int currentStep;
  final File? selfieImage;
  final File? idImage;

  const VerificationState({
    required this.currentStep,
    this.selfieImage,
    this.idImage,
  });

  @override
  List<Object?> get props => [currentStep, selfieImage, idImage];
}

class VerificationInitial extends VerificationState {
  const VerificationInitial() : super(currentStep: 0);
}

class VerificationInProgress extends VerificationState {
  const VerificationInProgress({
    required super.currentStep,
    super.selfieImage,
    super.idImage,
  });

  VerificationInProgress copyWith({
    int? currentStep,
    File? selfieImage,
    File? idImage,
  }) {
    return VerificationInProgress(
      currentStep: currentStep ?? this.currentStep,
      selfieImage: selfieImage ?? this.selfieImage,
      idImage: idImage ?? this.idImage,
    );
  }
}

class VerificationUploading extends VerificationState {
  const VerificationUploading({
    required super.currentStep,
    super.selfieImage,
    super.idImage,
  });
}

class VerificationSuccess extends VerificationState {
  const VerificationSuccess({
    required super.currentStep,
    super.selfieImage,
    super.idImage,
  });
}

class VerificationFailure extends VerificationState {
  final String message;

  const VerificationFailure({
    required super.currentStep,
    required this.message,
    super.selfieImage,
    super.idImage,
  });

  @override
  List<Object?> get props => [currentStep, message, selfieImage, idImage];
}

// ==================== BLOC ====================

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  VerificationBloc() : super(const VerificationInitial()) {
    on<GoToStep>(_onGoToStep);
    on<SelfieCaptured>(_onSelfieCaptured);
    on<IdCaptured>(_onIdCaptured);
    on<SubmitVerification>(_onSubmitVerification);
  }

  void _onGoToStep(GoToStep event, Emitter<VerificationState> emit) {
    emit(
      VerificationInProgress(
        currentStep: event.step,
        selfieImage: state.selfieImage,
        idImage: state.idImage,
      ),
    );
  }

  void _onSelfieCaptured(
    SelfieCaptured event,
    Emitter<VerificationState> emit,
  ) {
    if (state is VerificationInProgress) {
      final currentState = state as VerificationInProgress;
      emit(
        currentState.copyWith(selfieImage: event.selfieImage, currentStep: 2),
      );
    }
  }

  void _onIdCaptured(IdCaptured event, Emitter<VerificationState> emit) {
    if (state is VerificationInProgress) {
      final currentState = state as VerificationInProgress;
      emit(currentState.copyWith(idImage: event.idImage, currentStep: 3));
    }
  }

  Future<void> _onSubmitVerification(
    SubmitVerification event,
    Emitter<VerificationState> emit,
  ) async {
    if (state is VerificationInProgress) {
      final currentState = state as VerificationInProgress;
      emit(
        VerificationUploading(
          currentStep: currentState.currentStep,
          selfieImage: currentState.selfieImage,
          idImage: currentState.idImage,
        ),
      );

      try {
        // Simulate upload to Supabase Storage
        await Future.delayed(const Duration(seconds: 3));

        // In a real app:
        // final selfieUrl = await uploadFile(currentState.selfieImage!);
        // final idUrl = await uploadFile(currentState.idImage!);
        // await supabase.from('users').update({'selfie_url': selfieUrl, 'id_url': idUrl, 'is_verified': true});

        emit(
          VerificationSuccess(
            currentStep: currentState.currentStep,
            selfieImage: currentState.selfieImage,
            idImage: currentState.idImage,
          ),
        );
      } catch (e) {
        emit(
          VerificationFailure(
            currentStep: currentState.currentStep,
            message: 'Upload failed. Please try again.',
            selfieImage: currentState.selfieImage,
            idImage: currentState.idImage,
          ),
        );
      }
    }
  }
}
