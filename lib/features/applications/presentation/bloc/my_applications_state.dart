import '../../domain/models/application.dart';

abstract class MyApplicationsState {}

class MyApplicationsInitial extends MyApplicationsState {}

class MyApplicationsLoading extends MyApplicationsState {}

class MyApplicationsLoaded extends MyApplicationsState {
  final List<Application> applications;

  MyApplicationsLoaded({required this.applications});

  MyApplicationsLoaded copyWith({List<Application>? applications}) {
    return MyApplicationsLoaded(
      applications: applications ?? this.applications,
    );
  }

  List<Application> get pendingApplications =>
      applications.where((app) => app.status == 'pending').toList();

  List<Application> get acceptedApplications =>
      applications.where((app) => app.status == 'accepted').toList();

  List<Application> get rejectedApplications =>
      applications.where((app) => app.status == 'rejected').toList();
}

class MyApplicationsError extends MyApplicationsState {
  final String message;
  MyApplicationsError(this.message);
}
