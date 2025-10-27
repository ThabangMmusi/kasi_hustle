import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';
import 'package:kasi_hustle/features/profile/presentation/bloc/profile_event.dart';
import 'package:kasi_hustle/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
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
      // Simulate fetching from Supabase
      await Future.delayed(const Duration(seconds: 1));

      final profile = UserProfile(
        id: '1',
        name: 'Thabo Mkhize',
        email: 'thabo.mkhize@example.com',
        phone: '+27 82 456 7890',
        skills: ['Plumbing', 'Electrical', 'Carpentry'],
        bio:
            'Experienced handyman with 5+ years in the trade. Available for quick jobs around Soweto. Quality work guaranteed!',
        profileImage: null,
        rating: 4.7,
        totalReviews: 23,
        isVerified: true,
        userType: 'hustler',
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        completedJobs: 47,
      );

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

        final updatedProfile = currentState.profile.copyWith(
          name: event.name,
          phone: event.phone,
          skills: event.skills,
          bio: event.bio,
        );

        emit(ProfileLoaded(profile: updatedProfile, isEditing: false));
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
