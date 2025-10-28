import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';

abstract class OnboardingRepository {
  Future<UserProfile> createUserProfile({
    required String firstName,
    required String lastName,
    required String userType,
    required List<String> primarySkills,
    String? locationName,
    double? latitude,
    double? longitude,
  });

  Future<UserProfile> updateUserProfile(UserProfile profile);

  Future<void> requestVerification(String userId);
}
