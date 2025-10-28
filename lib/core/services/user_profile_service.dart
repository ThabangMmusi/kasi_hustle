import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized service for managing the current user's profile across the app
/// This ensures all features (home, search, profile, etc.) use the same user data
/// Data is fetched from Supabase and cached in memory during the session
class UserProfileService {
  // Singleton pattern to ensure one instance across the app
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  // Current user profile - cached from Supabase
  UserProfile? _currentUserProfile;
  bool _isInitialized = false;

  /// Get the current logged-in user's profile
  UserProfile? get currentUser => _currentUserProfile;

  /// Check if a user is currently logged in
  bool get isLoggedIn => _currentUserProfile != null;

  /// Check if the service has been initialized
  bool get isInitialized => _isInitialized;

  /// Initialize and load user profile from Supabase
  /// MUST be called in main() before runApp()
  /// Returns true if user is authenticated, false otherwise
  Future<bool> initialize() async {
    if (_isInitialized) return isLoggedIn;

    print('🔄 Initializing UserProfileService...');

    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;

      if (session != null) {
        print('✅ Supabase session found: ${session.user.id}');

        // Fetch user profile from Supabase
        final response = await supabase
            .from('profiles')
            .select()
            .eq('id', session.user.id)
            .single();

        _currentUserProfile = UserProfile.fromJson(response);
        print('✅ User profile loaded: ${_currentUserProfile?.firstName}');
      } else {
        print('ℹ️ No Supabase session found');
        _currentUserProfile = null;
      }
    } catch (e) {
      print('❌ Failed to initialize: $e');
      _currentUserProfile = null;
    }

    _isInitialized = true;
    print('✅ UserProfileService initialized (isLoggedIn: $isLoggedIn)');
    return isLoggedIn;
  }

  /// Set the current user profile (called by AppBloc)
  /// Does NOT save to Supabase - used for updating in-memory state
  void setUser(UserProfile? profile) {
    _currentUserProfile = profile;
    print('🔄 User profile updated: ${profile?.firstName ?? 'null'}');
  }

  /// Set the current user profile (called after auth/onboarding)
  /// Also saves to Supabase
  Future<void> setCurrentUser(UserProfile profile) async {
    _currentUserProfile = profile;

    final supabase = Supabase.instance.client;
    await supabase.from('profiles').upsert(profile.toJson());

    print('✅ User profile saved: ${profile.firstName} ${profile.lastName}');
  }

  /// Clear user data on logout
  /// Also signs out from Supabase
  Future<void> clearUser() async {
    _currentUserProfile = null;

    // Sign out from Supabase
    final supabase = Supabase.instance.client;
    await supabase.auth.signOut();

    print('🚪 User logged out, profile cleared');
  }

  /// Get user's current location (used by home and search features)
  Map<String, dynamic>? getUserLocation() {
    if (_currentUserProfile == null) return null;

    return {
      'locationName': _currentUserProfile!.locationName,
      'latitude': _currentUserProfile!.latitude,
      'longitude': _currentUserProfile!.longitude,
    };
  }

  /// Update user's location (used after location picker or GPS)
  void updateUserLocation({
    required String locationName,
    required double latitude,
    required double longitude,
  }) {
    if (_currentUserProfile == null) return;

    _currentUserProfile = _currentUserProfile!.copyWith(
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
    );

    // TODO: Save to storage and sync with Supabase
  }
}
