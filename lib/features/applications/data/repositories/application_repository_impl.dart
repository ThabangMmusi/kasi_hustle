import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/application.dart';
import '../../domain/repositories/application_repository.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  final SupabaseClient _supabaseClient;
  static const String _myAppsCacheKey = 'cached_my_applications';
  static const String _receivedAppsCacheKey = 'cached_received_applications';

  ApplicationRepositoryImpl(this._supabaseClient);

  @override
  Future<List<Application>> getMyApplications(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      // Fetch applications submitted by user with job details
      final applicationsData = await _supabaseClient
          .from('applications')
          .select(
            'id, job_id, status, applied_at, jobs(id, title, description, budget, location, latitude, longitude, created_by)',
          )
          .eq('user_id', userId)
          .order('applied_at', ascending: false);

      final List<Map<String, dynamic>> apps = List<Map<String, dynamic>>.from(
        applicationsData as List,
      );

      if (apps.isEmpty) return [];

      // 2. Extract unique job owner IDs
      final ownerIds = apps
          .map((app) {
            final job = app['jobs'] as Map<String, dynamic>?;
            return job?['created_by'] as String?;
          })
          .whereType<String>()
          .toSet()
          .toList();

      // 3. Fetch profiles for these owners
      Map<String, Map<String, dynamic>> profileMap = {};
      if (ownerIds.isNotEmpty) {
        final profilesData = await _supabaseClient
            .from('profiles')
            .select('id, first_name, last_name')
            .filter('id', 'in', ownerIds);

        for (var profile in (profilesData as List)) {
          profileMap[profile['id']] = profile as Map<String, dynamic>;
        }
      }

      // 4. Map everything to Application objects
      final applications = apps.map((app) {
        final job = app['jobs'] as Map<String, dynamic>? ?? {};
        final ownerId = job['created_by'] as String? ?? '';
        final profile = profileMap[ownerId];

        final ownerName = profile != null
            ? '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'
                  .trim()
            : 'Unknown';

        return Application(
          id: app['id'] as String,
          jobId: app['job_id'] as String,
          jobTitle: job['title'] as String? ?? 'Unknown Job',
          jobDescription: job['description'] as String? ?? '',
          budget: (job['budget'] as num?)?.toDouble() ?? 0.0,
          location: job['location'] as String? ?? 'Unknown Location',
          latitude: (job['latitude'] as num?)?.toDouble() ?? 0.0,
          longitude: (job['longitude'] as num?)?.toDouble() ?? 0.0,
          applicantId: userId,
          applicantName: '',
          message: '',
          status: app['status'] as String? ?? 'pending',
          appliedAt: DateTime.parse(
            app['applied_at'] as String? ?? DateTime.now().toIso8601String(),
          ),
          jobOwnerId: ownerId,
          jobOwnerName: ownerName.isEmpty ? 'Kasi Hustle User' : ownerName,
        );
      }).toList();

      // Cache the results
      final appsJson = applications.map((app) => app.toJson()).toList();
      await prefs.setString(_myAppsCacheKey, jsonEncode(appsJson));

      return applications;
    } catch (e) {
      // Fallback to cache
      final cachedString = prefs.getString(_myAppsCacheKey);
      if (cachedString != null) {
        final List<dynamic> jsonList = jsonDecode(cachedString);
        return jsonList.map((json) => Application.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch applications: $e');
    }
  }

  @override
  Future<List<Application>> getReceivedApplications(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      // Fetch applications for jobs posted by user
      final applicationsData = await _supabaseClient
          .from('applications')
          .select(
            'id, job_id, status, applied_at, user_id, jobs!inner(id, title, description, budget, location, latitude, longitude, created_by), profiles!user_id(first_name, last_name)',
          )
          .eq('jobs.created_by', userId)
          .order('applied_at', ascending: false);

      final applications = (applicationsData as List).map((app) {
        final job = app['jobs'] as Map<String, dynamic>;
        final profileList = app['profiles'] as List?;
        final profile = (profileList != null && profileList.isNotEmpty)
            ? profileList[0] as Map<String, dynamic>
            : null;

        final applicantName = profile != null
            ? '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'
                  .trim()
            : 'Unknown';

        return Application(
          id: app['id'] as String,
          jobId: app['job_id'] as String,
          jobTitle: job['title'] as String? ?? 'Unknown Job',
          jobDescription: job['description'] as String? ?? '',
          budget: (job['budget'] as num?)?.toDouble() ?? 0.0,
          location: job['location'] as String? ?? 'Unknown Location',
          latitude: (job['latitude'] as num?)?.toDouble() ?? 0.0,
          longitude: (job['longitude'] as num?)?.toDouble() ?? 0.0,
          applicantId: app['user_id'] as String? ?? '',
          applicantName: applicantName.isEmpty
              ? 'Unknown Applicant'
              : applicantName,
          message: '',
          status: app['status'] as String? ?? 'pending',
          appliedAt: DateTime.parse(
            app['applied_at'] as String? ?? DateTime.now().toIso8601String(),
          ),
          jobOwnerId: job['created_by'] as String? ?? '',
          jobOwnerName: '',
        );
      }).toList();

      // Cache the results
      final appsJson = applications.map((app) => app.toJson()).toList();
      await prefs.setString(_receivedAppsCacheKey, jsonEncode(appsJson));

      return applications;
    } catch (e) {
      // Fallback to cache
      final cachedString = prefs.getString(_receivedAppsCacheKey);
      if (cachedString != null) {
        final List<dynamic> jsonList = jsonDecode(cachedString);
        return jsonList.map((json) => Application.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch received applications: $e');
    }
  }

  @override
  Future<void> withdrawApplication(String applicationId) async {
    try {
      await _supabaseClient
          .from('applications')
          .delete()
          .eq('id', applicationId);
    } catch (e) {
      throw Exception('Failed to withdraw application: $e');
    }
  }

  @override
  Future<void> updateApplicationStatus(
    String applicationId,
    String status,
  ) async {
    try {
      await _supabaseClient
          .from('applications')
          .update({'status': status})
          .eq('id', applicationId);
    } catch (e) {
      throw Exception('Failed to update application status: $e');
    }
  }
}
