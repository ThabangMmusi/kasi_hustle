import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';
import 'package:kasi_hustle/features/home/domain/repositories/home_repository.dart';

typedef GetUserProfile = Future<UserProfile> Function();

GetUserProfile makeGetUserProfile(HomeRepository repository) {
  return () => repository.getUserProfile();
}
