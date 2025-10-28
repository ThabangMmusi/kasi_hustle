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
    on<AppProfileCreated>(_onAppProfileCreated);

    // Listen to Supabase auth state changes
    // This stream fires immediately with the initial session, so no need to check currentSession
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      final session = data.session;
      final user = session?.user;
      print('🔐 Auth state change: event=${data.event}, user=${user?.email}');
      add(AppUserChanged(user));
    });
  }

  Future<void> _onAppUserChanged(
    AppUserChanged event,
    Emitter<AppState> emit,
  ) async {
    final supabaseUser = event.user;

    print('👤 APP USER CHANGED: user=${supabaseUser?.email}');

    if (supabaseUser != null) {
      // FIRST: Emit loading state to signal router we're working on it
      print('⏳ Emitting loading state...');
      // emit(AppState.loading());

      print('🔍 Fetching profile for user: ${supabaseUser.id}');

      try {
        // SECOND: Try to load user profile from database
        final response = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', supabaseUser.id)
            .maybeSingle();

        print(
          '📊 Profile query result: ${response != null ? "Found" : "Not found"}',
        );

        UserProfile? userProfile;
        bool isCompleteProfile = false; // Default to false

        if (response == null) {
          // NEW USER - No profile found in database
          print(
            '🆕 New user detected - creating temporary profile from auth metadata',
          );

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
          print('✅ Existing user detected - loading profile from database');

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

          print(
            '📋 Profile validation: name=$hasName, userType=$hasUserType, skills=$hasRequiredSkills → complete=$isCompleteProfile',
          );
        }

        // Update UserProfileService with loaded profile
        _userProfileService.setUser(userProfile);

        // FINALLY: Emit authenticated state with complete information
        print(
          '✨ Emitting authenticated state: profileCompleted=$isCompleteProfile',
        );
        print('   📌 User: ${userProfile.firstName} ${userProfile.lastName}');
        print('   📌 UserType: ${userProfile.userType}');
        print('   📌 Primary Skills: ${userProfile.primarySkills}');
        emit(
          AppState.authenticated(
            user: userProfile,
            profileCompleted: isCompleteProfile,
          ),
        );
      } catch (e) {
        print('❌ Error loading user profile: $e');
        emit(const AppState.unauthenticated());
      }
    } else {
      // No user logged in
      print('🚫 No user - setting unauthenticated');
      _userProfileService.setUser(null);
      emit(const AppState.unauthenticated());
    }
  }

  Future<void> _onAppLogoutRequested(
    AppLogoutRequested event,
    Emitter<AppState> emit,
  ) async {
    print('🚪 Logout requested');
    // Emit unauthenticated state immediately
    emit(const AppState.unauthenticated());
    // Clear user profile and sign out from Supabase
    _userProfileService.setUser(null);
    await _userProfileService.clearUser();
    print('✅ Logged out successfully');
  }

  Future<void> _onAppProfileCreated(
    AppProfileCreated event,
    Emitter<AppState> emit,
  ) async {
    print(
      '✨ Profile created: ${event.profile.firstName} ${event.profile.lastName}',
    );

    // Update UserProfileService with the created profile
    _userProfileService.setUser(event.profile);

    // Emit authenticated state with complete profile
    emit(AppState.authenticated(user: event.profile, profileCompleted: true));
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
