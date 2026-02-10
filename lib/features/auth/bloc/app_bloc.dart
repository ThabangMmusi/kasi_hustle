import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kasi_hustle/core/services/user_profile_service.dart';
import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final UserProfileService _userProfileService;
  late StreamSubscription<AuthState> _authSubscription;

  AppBloc({required UserProfileService userProfileService})
    : _userProfileService = userProfileService,
      super(const AppState.unknown()) {
    on<AppUserChanged>(_onAppUserChanged);
    on<AppLogoutRequested>(_onAppLogoutRequested);
    on<AppDeleteAccountRequested>(_onAppDeleteAccountRequested);
    on<AppProfileCreated>(_onAppProfileCreated);

    // Listen to Supabase auth state changes
    // This stream fires immediately with the initial session, so no need to check currentSession
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      final session = data.session;
      final user = session?.user;
      add(AppUserChanged(user));
    });
  }

  Future<void> _onAppUserChanged(
    AppUserChanged event,
    Emitter<AppState> emit,
  ) async {
    final supabaseUser = event.user;

    if (supabaseUser != null) {
      // FIRST: Emit loading state to signal router we're working on it
      // emit(AppState.loading());

      try {
        // SECOND: Try to load user profile from database
        final response = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', supabaseUser.id)
            .maybeSingle();

        UserProfile? userProfile;
        bool isCompleteProfile = false; // Default to false

        if (response == null) {
          // NEW USER - No profile found in database
          final displayName =
              supabaseUser.userMetadata?['full_name'] ?? supabaseUser.email;

          String? firstName;
          String? lastName;

          if (displayName != null) {
            // Clean the display name (remove parentheses content)
            String cleanedDisplayName = displayName.replaceAll(
              RegExp(r'\s*\(.*?\)\s*'),
              '',
            );

            final parts = cleanedDisplayName.split(' ');
            if (parts.isNotEmpty) {
              if (parts.length > 1) {
                firstName = parts.sublist(0, parts.length - 1).join(' ');
                lastName = parts.last;
              } else {
                firstName = parts[0];
                lastName = "";
              }
            }
          }

          // Create incomplete profile with Google data
          userProfile = UserProfile(
            id: supabaseUser.id,
            firstName: firstName ?? '',
            lastName: lastName ?? '',
            primarySkills: [],
            userType: 'hustler', // Default
            rating: 0.0,
            totalReviews: 0,
            isVerified: false,
            createdAt: DateTime.now(),
            completedJobs: 0,
          );

          isCompleteProfile = false; // New user needs onboarding
        } else {
          // EXISTING USER - Profile found in database
          userProfile = UserProfile.fromJson(response);

          // THIRD: Validate if profile is complete
          final hasName =
              userProfile.firstName.isNotEmpty &&
              userProfile.lastName.isNotEmpty;
          final hasUserType = userProfile.userType.isNotEmpty;

          // For hustlers, require at least one primary skill
          final hasRequiredSkills =
              userProfile.userType != 'hustler' ||
              userProfile.primarySkills.isNotEmpty;

          isCompleteProfile = hasName && hasUserType && hasRequiredSkills;
        }

        // Update UserProfileService with loaded profile
        _userProfileService.setUser(userProfile);

        // FINALLY: Emit authenticated state with complete information
        emit(
          AppState.authenticated(
            user: userProfile,
            profileCompleted: isCompleteProfile,
          ),
        );
      } catch (e) {
        emit(const AppState.unauthenticated());
      }
    } else {
      // No user logged in
      _userProfileService.setUser(null);
      emit(const AppState.unauthenticated());
    }
  }

  Future<void> _onAppLogoutRequested(
    AppLogoutRequested event,
    Emitter<AppState> emit,
  ) async {
    // Emit unauthenticated state immediately
    emit(const AppState.unauthenticated());
    // Clear user profile and sign out from Supabase
    _userProfileService.setUser(null);
    await _userProfileService.clearUser();
  }

  Future<void> _onAppProfileCreated(
    AppProfileCreated event,
    Emitter<AppState> emit,
  ) async {
    // Update UserProfileService with the created profile
    _userProfileService.setUser(event.profile);

    // Emit authenticated state with complete profile
    emit(AppState.authenticated(user: event.profile, profileCompleted: true));
  }

  Future<void> _onAppDeleteAccountRequested(
    AppDeleteAccountRequested event,
    Emitter<AppState> emit,
  ) async {
    final user = state.user;
    if (user == null) return;

    try {
      // Delete profile from Supabase
      await Supabase.instance.client
          .from('profiles')
          .delete()
          .eq('id', user.id);

      // Trigger logout to clear state and sign out
      add(const AppLogoutRequested());
    } catch (e) {
      print('❌ Failed to delete account: $e');
      // We might want to emit an error state here, but for now just logout
      add(const AppLogoutRequested());
    }
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
