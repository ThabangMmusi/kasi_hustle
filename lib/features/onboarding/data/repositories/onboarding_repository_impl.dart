import 'package:kasi_hustle/features/onboarding/data/datasources/onboarding_data_source.dart';
import 'package:kasi_hustle/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingDataSource dataSource;

  OnboardingRepositoryImpl(this.dataSource);

  @override
  Future<UserProfile> createUserProfile({
    required String firstName,
    required String lastName,
    required String userType,
    required List<String> primarySkills,
    String? locationName,
    double? latitude,
    double? longitude,
  }) {
    return dataSource.createUserProfile(
      firstName: firstName,
      lastName: lastName,
      userType: userType,
      primarySkills: primarySkills,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  Future<UserProfile> updateUserProfile(UserProfile profile) {
    return dataSource.updateUserProfile(profile);
  }

  @override
  Future<void> requestVerification(String userId) {
    return dataSource.requestVerification(userId);
  }
}
