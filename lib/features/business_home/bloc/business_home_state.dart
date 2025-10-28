part of 'business_home_bloc.dart';

abstract class BusinessHomeState {}

class BusinessHomeLoading extends BusinessHomeState {}

class BusinessHomeError extends BusinessHomeState {
  final String message;
  BusinessHomeError(this.message);
}

class BusinessHomeLoaded extends BusinessHomeState {
  final List<Job> postedJobs;
  BusinessHomeLoaded(this.postedJobs);
}
