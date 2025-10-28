import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';

abstract class OnboardingState {
  final int currentStep;
  final String? userType;
  final String? firstName;
  final String? lastName;
  final List<String> selectedSkills;
  final String? locationName;
  final double? latitude;
  final double? longitude;

  OnboardingState({
    required this.currentStep,
    this.userType,
    this.firstName,
    this.lastName,
    this.selectedSkills = const [],
    this.locationName,
    this.latitude,
    this.longitude,
  });
}

class OnboardingLocationLoading extends OnboardingState {
  OnboardingLocationLoading({
    required super.currentStep,
    super.userType,
    super.firstName,
    super.lastName,
    super.selectedSkills,
    super.locationName,
    super.latitude,
    super.longitude,
  });
}

class OnboardingInProgress extends OnboardingState {
  OnboardingInProgress({
    required super.currentStep,
    super.userType,
    super.firstName,
    super.lastName,
    super.selectedSkills,
    super.locationName,
    super.latitude,
    super.longitude,
  });

  OnboardingInProgress copyWith({
    int? currentStep,
    String? userType,
    String? firstName,
    String? lastName,
    List<String>? selectedSkills,
    String? locationName,
    double? latitude,
    double? longitude,
  }) {
    return OnboardingInProgress(
      currentStep: currentStep ?? this.currentStep,
      userType: userType ?? this.userType,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      selectedSkills: selectedSkills ?? this.selectedSkills,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class OnboardingSubmitting extends OnboardingState {
  OnboardingSubmitting({
    required super.currentStep,
    super.userType,
    super.firstName,
    super.lastName,
    super.selectedSkills,
    super.locationName,
    super.latitude,
    super.longitude,
  });
}

class OnboardingComplete extends OnboardingState {
  final bool needsVerification;
  final UserProfile createdProfile;

  OnboardingComplete({
    required super.currentStep,
    required this.needsVerification,
    required this.createdProfile,
    super.userType,
    super.firstName,
    super.lastName,
    super.selectedSkills,
    super.locationName,
    super.latitude,
    super.longitude,
  });
}

class OnboardingError extends OnboardingState {
  final String message;

  OnboardingError({
    required super.currentStep,
    required this.message,
    super.userType,
    super.firstName,
    super.lastName,
    super.selectedSkills,
    super.locationName,
    super.latitude,
    super.longitude,
  });
}
