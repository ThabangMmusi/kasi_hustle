import 'dart:convert';
import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const String _profileCacheKey = 'cached_user_profile';

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
    final prefs = await SharedPreferences.getInstance();

    // 1. Load from Cache First
    final cachedJson = prefs.getString(_profileCacheKey);
    if (cachedJson != null) {
      try {
        _currentUserProfile = UserProfile.fromJson(jsonDecode(cachedJson));
        print('✅ User profile loaded from cache');
      } catch (e) {
        print('⚠️ Failed to load profile from cache: $e');
      }
    }

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

        var profile = UserProfile.fromJson(response);

        // Inject Email from Auth Session (as it's not in public profiles usually)
        if (session.user.email != null) {
          profile = profile.copyWith(email: session.user.email);
        }

        _currentUserProfile = profile;

        // Update Cache
        await prefs.setString(
          _profileCacheKey,
          jsonEncode(_currentUserProfile!.toJson()),
        );

        print(
          '✅ User profile loaded from network: ${_currentUserProfile?.firstName}',
        );
      } else {
        print('ℹ️ No Supabase session found');
        if (supabase.auth.currentUser == null) {
          _currentUserProfile = null;
        }
      }
    } catch (e) {
      print('❌ Failed to initialize from network: $e');
      // Keep cached profile if we have it
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
    final supabase = Supabase.instance.client;

    // Check if email changed explicitly and update Auth
    // Note: This often triggers email confirmation flow
    if (profile.email != null && _currentUserProfile?.email != profile.email) {
      try {
        await supabase.auth.updateUser(UserAttributes(email: profile.email));
        print('📧 Auth email update requested: ${profile.email}');
      } catch (e) {
        print('⚠️ Failed to update auth email: $e');
        // Depending on requirements, we might want to rethrow or inform user
      }
    }

    _currentUserProfile = profile;

    // Remove email from JSON for profile table update if it's not a column
    // The model's toJson should hopefully handle this or we rely on Postgres ignoring extra json fields if passed as jsonb,
    // BUT supbase .upsert expects exact columns usually.
    // Ensure UserProfile.toJson() DOES NOT include 'email' if it's not in DB.
    // I modified UserProfile.toJson to commented out email, so it should suffice.
    // However, phone_number IS in toJson now.

    await supabase.from('profiles').upsert(profile.toJson());

    // Update Cache
    final prefs = await SharedPreferences.getInstance();
    // For cache, we WANT email. But toJson excludes it.
    // We should probably include it in cache.
    // Let's create a full json for cache.
    final cacheJson = profile.toJson();
    if (profile.email != null) cacheJson['email'] = profile.email;

    await prefs.setString(_profileCacheKey, jsonEncode(cacheJson));

    print('✅ User profile saved: ${profile.firstName} ${profile.lastName}');
  }

  /// Clear user data on logout
  /// Also signs out from Supabase
  Future<void> clearUser() async {
    _currentUserProfile = null;

    // Sign out from Supabase
    final supabase = Supabase.instance.client;
    await supabase.auth.signOut();

    // Clear Cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileCacheKey);

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
