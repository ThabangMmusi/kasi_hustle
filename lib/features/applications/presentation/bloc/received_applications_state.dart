part of 'received_applications_bloc.dart';

abstract class ReceivedApplicationsState {}

class ReceivedApplicationsInitial extends ReceivedApplicationsState {}

class ReceivedApplicationsLoading extends ReceivedApplicationsState {}

class ReceivedApplicationsLoaded extends ReceivedApplicationsState {
  final List<Application> applications;

  ReceivedApplicationsLoaded({required this.applications});

  ReceivedApplicationsLoaded copyWith({List<Application>? applications}) {
    return ReceivedApplicationsLoaded(
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

class ReceivedApplicationsError extends ReceivedApplicationsState {
  final String message;
  ReceivedApplicationsError(this.message);
}
