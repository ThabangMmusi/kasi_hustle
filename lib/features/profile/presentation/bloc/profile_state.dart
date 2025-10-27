import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  final bool isEditing;

  ProfileLoaded({required this.profile, this.isEditing = false});

  ProfileLoaded copyWith({UserProfile? profile, bool? isEditing}) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}

class ProfileUpdating extends ProfileState {
  final UserProfile profile;
  ProfileUpdating(this.profile);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
