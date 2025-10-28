abstract class MyApplicationsEvent {}

class LoadMyApplications extends MyApplicationsEvent {}

class WithdrawMyApplication extends MyApplicationsEvent {
  final String applicationId;
  WithdrawMyApplication(this.applicationId);
}
