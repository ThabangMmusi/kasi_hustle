import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasi_hustle/core/services/user_profile_service.dart';
import 'package:kasi_hustle/features/verification/domain/usecases/submit_verification_usecase.dart';
import 'verification_event.dart';
import 'verification_state.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  final SubmitVerificationUseCase submitVerificationUseCase;
  final UserProfileService userProfileService;

  VerificationBloc({
    required this.submitVerificationUseCase,
    required this.userProfileService,
  }) : super(const VerificationState()) {
    on<StartVerification>(
      (event, emit) =>
          emit(state.copyWith(status: VerificationFlowStatus.instructions)),
    );
    on<SelfieCaptured>(
      (event, emit) => emit(
        state.copyWith(
          status: VerificationFlowStatus.selfiePreview,
          selfieImage: event.selfieImage,
        ),
      ),
    );
    on<IdCaptured>(
      (event, emit) => emit(
        state.copyWith(
          status: VerificationFlowStatus.idPreview,
          idImage: event.idImage,
        ),
      ),
    );
    on<RetakeSelfie>(
      (event, emit) =>
          emit(state.copyWith(status: VerificationFlowStatus.selfieCapture)),
    );
    on<RetakeId>(
      (event, emit) =>
          emit(state.copyWith(status: VerificationFlowStatus.idCapture)),
    );
    on<SubmitVerification>(_onSubmitVerification);
    on<GoToPreviousStep>(_onGoToPreviousStep);
  }

  void _onGoToPreviousStep(
    GoToPreviousStep event,
    Emitter<VerificationState> emit,
  ) {
    switch (state.status) {
      case VerificationFlowStatus.selfieCapture:
        emit(state.copyWith(status: VerificationFlowStatus.instructions));
        break;
      case VerificationFlowStatus.selfiePreview:
        emit(state.copyWith(status: VerificationFlowStatus.selfieCapture));
        break;
      case VerificationFlowStatus.idCapture:
        emit(state.copyWith(status: VerificationFlowStatus.selfiePreview));
        break;
      case VerificationFlowStatus.idPreview:
        emit(state.copyWith(status: VerificationFlowStatus.idCapture));
        break;
      default:
        break;
    }
  }

  Future<void> _onSubmitVerification(
    SubmitVerification event,
    Emitter<VerificationState> emit,
  ) async {
    if (state.selfieImage == null || state.idImage == null) {
      emit(
        state.copyWith(
          status: VerificationFlowStatus.failure,
          errorMessage: 'Both selfie and ID images are required',
        ),
      );
      return;
    }

    emit(state.copyWith(status: VerificationFlowStatus.uploading));

    try {
      final userId = userProfileService.currentUser?.id ?? 'unknown';

      // Submit verification through use case
      await submitVerificationUseCase(
        userId: userId,
        selfieImage: state.selfieImage!,
        idImage: state.idImage!,
      );

      emit(state.copyWith(status: VerificationFlowStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: VerificationFlowStatus.failure,
          errorMessage: 'Verification failed: ${e.toString()}',
        ),
      );
    }
  }
}
