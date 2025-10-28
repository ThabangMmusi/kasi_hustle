part of 'received_applications_bloc.dart';

abstract class ReceivedApplicationsEvent {}

class LoadReceivedApplications extends ReceivedApplicationsEvent {}

class RejectApplicationEvent extends ReceivedApplicationsEvent {
  final String applicationId;
  RejectApplicationEvent(this.applicationId);
}

class AcceptApplicationEvent extends ReceivedApplicationsEvent {
  final String applicationId;
  AcceptApplicationEvent(this.applicationId);
}
