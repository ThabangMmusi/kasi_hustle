import '../models/application.dart';

abstract class ApplicationRepository {
  /// Get all applications submitted by current user (Hustler view)
  Future<List<Application>> getMyApplications(String userId);

  /// Get all applications received on current user's jobs (Provider view)
  Future<List<Application>> getReceivedApplications(String userId);

  /// Withdraw application by user
  Future<void> withdrawApplication(String applicationId);

  /// Update application status by job provider
  Future<void> updateApplicationStatus(String applicationId, String status);
}
