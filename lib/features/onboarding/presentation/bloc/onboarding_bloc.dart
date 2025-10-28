import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasi_hustle/core/services/location_service.dart';
import 'package:kasi_hustle/features/onboarding/domain/usecases/create_user_profile.dart';
import 'package:kasi_hustle/features/onboarding/domain/usecases/request_verification.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final CreateUserProfile createUserProfile;
  final RequestVerification requestVerification;
  final LocationService locationService;

  OnboardingBloc({
    required this.createUserProfile,
    required this.requestVerification,
    required this.locationService,
    String? initialFirstName,
    String? initialLastName,
  }) : super(
         OnboardingInProgress(
           currentStep: 0,
           firstName: initialFirstName,
           lastName: initialLastName,
         ),
       ) {
    on<NextStep>(_onNextStep);
    on<PreviousStep>(_onPreviousStep);
    on<SelectUserType>(_onSelectUserType);
    on<UpdateName>(_onUpdateName);
    on<ToggleSkill>(_onToggleSkill);
    on<CompleteOnboarding>(_onCompleteOnboarding);
    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<UpdateLocation>(_onUpdateLocation);
  }

  void _onNextStep(NextStep event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      final maxSteps = currentState.userType == 'hustler'
          ? 5
          : 4; // Increased max steps

      if (currentState.currentStep < maxSteps) {
        emit(currentState.copyWith(currentStep: currentState.currentStep + 1));
      }
    }
  }

  void _onPreviousStep(PreviousStep event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      if (currentState.currentStep > 0) {
        emit(currentState.copyWith(currentStep: currentState.currentStep - 1));
      }
    }
  }

  void _onSelectUserType(SelectUserType event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(userType: event.userType));
    }
  }

  void _onUpdateName(UpdateName event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(
        currentState.copyWith(
          firstName: event.firstName,
          lastName: event.lastName,
        ),
      );
    }
  }

  void _onToggleSkill(ToggleSkill event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      final skills = List<String>.from(currentState.selectedSkills);

      if (skills.contains(event.skill)) {
        skills.remove(event.skill);
      } else {
        if (skills.length < 5) {
          skills.add(event.skill);
        }
      }

      emit(currentState.copyWith(selectedSkills: skills));
    }
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocation event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(
        OnboardingLocationLoading(
          currentStep: currentState.currentStep,
          userType: currentState.userType,
          firstName: currentState.firstName,
          lastName: currentState.lastName,
          selectedSkills: currentState.selectedSkills,
        ),
      );
      try {
        final locationData = await locationService.getCurrentLocation();

        emit(
          currentState.copyWith(
            locationName: locationData.locationName,
            latitude: locationData.latitude,
            longitude: locationData.longitude,
          ),
        );
      } catch (e) {
        emit(
          OnboardingError(
            currentStep: currentState.currentStep,
            message: e.toString().replaceAll('Exception: ', ''),
          ),
        );
        // Return to in-progress state
        emit(currentState);
      }
    }
  }

  void _onUpdateLocation(UpdateLocation event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(
        currentState.copyWith(
          locationName: event.locationName,
          latitude: event.latitude,
          longitude: event.longitude,
        ),
      );
    }
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;

      emit(
        OnboardingSubmitting(
          currentStep: currentState.currentStep,
          userType: currentState.userType,
          firstName: currentState.firstName,
          lastName: currentState.lastName,
          selectedSkills: currentState.selectedSkills,
          locationName: currentState.locationName,
          latitude: currentState.latitude,
          longitude: currentState.longitude,
        ),
      );

      try {
        // Create user profile
        // For job providers, skills are optional - only hustlers require skills
        final primarySkills = currentState.userType == 'hustler'
            ? currentState.selectedSkills
            : <String>[]; // Empty list for job providers

        final profile = await createUserProfile(
          firstName: currentState.firstName ?? '',
          lastName: currentState.lastName ?? '',
          userType: currentState.userType ?? 'hustler',
          primarySkills: primarySkills,
          locationName: currentState.locationName,
          latitude: currentState.latitude,
          longitude: currentState.longitude,
        );

        // Request verification if user chose to verify now
        if (event.verifyNow) {
          await requestVerification(profile.id);
        }

        emit(
          OnboardingComplete(
            currentStep: currentState.currentStep,
            needsVerification: event.verifyNow,
            createdProfile: profile,
            userType: currentState.userType,
            firstName: currentState.firstName,
            lastName: currentState.lastName,
            selectedSkills: currentState.selectedSkills,
            locationName: currentState.locationName,
            latitude: currentState.latitude,
            longitude: currentState.longitude,
          ),
        );
      } catch (e) {
        print('❌ Onboarding error: $e');
        emit(
          OnboardingError(
            currentStep: currentState.currentStep,
            message: 'Failed to complete onboarding: ${e.toString()}',
          ),
        );
        // Return to in-progress state
        emit(currentState);
      }
    }
  }
}
