import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/application.dart';
import '../../domain/repositories/application_repository.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  final SupabaseClient _supabaseClient;

  ApplicationRepositoryImpl(this._supabaseClient);

  @override
  Future<List<Application>> getMyApplications(String userId) async {
    try {
      // Fetch applications submitted by user with job details
      final applicationsData = await _supabaseClient
          .from('applications')
          .select(
            'id, job_id, status, applied_at, jobs(id, title, description, budget, location, latitude, longitude, created_by)',
          )
          .eq('user_id', userId)
          .order('applied_at', ascending: false);

      return (applicationsData as List).map((app) {
        final job = app['jobs'] as Map<String, dynamic>;
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
          jobOwnerId: job['created_by'] as String? ?? '',
          jobOwnerName: '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch applications: $e');
    }
  }

  @override
  Future<List<Application>> getReceivedApplications(String userId) async {
    try {
      // Fetch applications for jobs posted by user
      final applicationsData = await _supabaseClient
          .from('applications')
          .select(
            'id, job_id, status, applied_at, user_id, jobs!inner(id, title, description, budget, location, latitude, longitude, created_by), profiles!user_id(full_name)',
          )
          .eq('jobs.created_by', userId)
          .order('applied_at', ascending: false);

      return (applicationsData as List).map((app) {
        final job = app['jobs'] as Map<String, dynamic>;
        final profiles = (app['profiles'] as List).isNotEmpty
            ? app['profiles'][0] as Map<String, dynamic>
            : {};

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
          applicantName:
              profiles['full_name'] as String? ?? 'Unknown Applicant',
          message: '',
          status: app['status'] as String? ?? 'pending',
          appliedAt: DateTime.parse(
            app['applied_at'] as String? ?? DateTime.now().toIso8601String(),
          ),
          jobOwnerId: job['created_by'] as String? ?? '',
          jobOwnerName: '',
        );
      }).toList();
    } catch (e) {
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
