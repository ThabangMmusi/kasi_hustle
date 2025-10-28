import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasi_hustle/core/services/user_profile_service.dart';
import 'package:kasi_hustle/features/profile/presentation/bloc/profile_event.dart';
import 'package:kasi_hustle/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserProfileService _userProfileService;

  ProfileBloc({required UserProfileService userProfileService})
    : _userProfileService = userProfileService,
      super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UploadProfileImage>(_onUploadProfileImage);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      // Get current user from UserProfileService
      final profile = _userProfileService.currentUser;
      if (profile == null) {
        emit(ProfileError('User not logged in'));
        return;
      }

      emit(ProfileLoaded(profile: profile));
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(ProfileUpdating(currentState.profile));

      try {
        await Future.delayed(const Duration(seconds: 1));

        // Simply use the updated profile from the event
        emit(ProfileLoaded(profile: event.profile, isEditing: false));
      } catch (e) {
        emit(ProfileError('Failed to update profile: $e'));
      }
    }
  }

  Future<void> _onUploadProfileImage(
    UploadProfileImage event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(ProfileUpdating(currentState.profile));

      try {
        await Future.delayed(const Duration(seconds: 1));

        final updatedProfile = currentState.profile.copyWith(
          profileImage: event.imagePath,
        );

        emit(ProfileLoaded(profile: updatedProfile));
      } catch (e) {
        emit(ProfileError('Failed to upload image: $e'));
      }
    }
  }
}
