import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';

abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final UserProfile profile;

  UpdateProfile({required this.profile});
}

class UploadProfileImage extends ProfileEvent {
  final String imagePath;
  UploadProfileImage(this.imagePath);
}
