import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class OnboardingDataSource {
  Future<UserProfile> createUserProfile({
    required String firstName,
    required String lastName,
    required String userType,
    required List<String> primarySkills,
    String? locationName,
    double? latitude,
    double? longitude,
  });

  Future<UserProfile> updateUserProfile(UserProfile profile);

  Future<void> requestVerification(String userId);
}

class OnboardingLocalDataSource implements OnboardingDataSource {
  final _supabase = Supabase.instance.client;

  @override
  Future<UserProfile> createUserProfile({
    required String firstName,
    required String lastName,
    required String userType,
    required List<String> primarySkills,
    String? locationName,
    double? latitude,
    double? longitude,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Insert profile into Supabase
    final response = await _supabase
        .from('profiles')
        .insert({
          'id': userId,
          'first_name': firstName,
          'last_name': lastName,
          'user_type': userType,
          'primary_skills': primarySkills,
          'location_name': locationName,
          'latitude': latitude,
          'longitude': longitude,
        })
        .select()
        .single();

    return UserProfile.fromJson(response);
  }

  @override
  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    final response = await _supabase
        .from('profiles')
        .update(profile.toJson())
        .eq('id', profile.id)
        .select()
        .single();

    return UserProfile.fromJson(response);
  }

  @override
  Future<void> requestVerification(String userId) async {
    // TODO: Implement verification request logic
    // For now, just update is_verified status or create verification request
    await _supabase
        .from('profiles')
        .update({
          'is_verified': false, // Keep false, pending verification
        })
        .eq('id', userId);
  }
}
