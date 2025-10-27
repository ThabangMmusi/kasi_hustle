abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final String name;
  final String? phone;
  final List<String> skills;
  final String? bio;

  UpdateProfile({
    required this.name,
    this.phone,
    required this.skills,
    this.bio,
  });
}

class UploadProfileImage extends ProfileEvent {
  final String imagePath;
  UploadProfileImage(this.imagePath);
}
