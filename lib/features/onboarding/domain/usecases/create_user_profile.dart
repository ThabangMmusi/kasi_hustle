import 'package:kasi_hustle/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';

class CreateUserProfile {
  final OnboardingRepository repository;

  CreateUserProfile(this.repository);

  Future<UserProfile> call({
    required String firstName,
    required String lastName,
    required String userType,
    required List<String> primarySkills,
    String? locationName,
    double? latitude,
    double? longitude,
  }) {
    return repository.createUserProfile(
      firstName: firstName,
      lastName: lastName,
      userType: userType,
      primarySkills: primarySkills,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
