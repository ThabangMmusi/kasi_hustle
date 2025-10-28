abstract class OnboardingEvent {}

class NextStep extends OnboardingEvent {}

class PreviousStep extends OnboardingEvent {}

class SelectUserType extends OnboardingEvent {
  final String userType;
  SelectUserType(this.userType);
}

class UpdateName extends OnboardingEvent {
  final String firstName;
  final String lastName;
  UpdateName({required this.firstName, required this.lastName});
}

class ToggleSkill extends OnboardingEvent {
  final String skill;
  ToggleSkill(this.skill);
}

class CompleteOnboarding extends OnboardingEvent {
  final bool verifyNow;
  CompleteOnboarding(this.verifyNow);
}

class GetCurrentLocation extends OnboardingEvent {}

class UpdateLocation extends OnboardingEvent {
  final String locationName;
  final double latitude;
  final double longitude;

  UpdateLocation({
    required this.locationName,
    required this.latitude,
    required this.longitude,
  });
}
