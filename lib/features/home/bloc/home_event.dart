part of 'home_bloc.dart';

abstract class HomeEvent {}

class LoadHomeData extends HomeEvent {}

class RefreshHomeData extends HomeEvent {}

class SearchJobsEvent extends HomeEvent {
  final String query;
  SearchJobsEvent(this.query);
}

class FilterBySkill extends HomeEvent {
  final String skill;
  FilterBySkill(this.skill);
}

class SubmitJobApplication extends HomeEvent {
  final String jobId;
  final String userId;

  SubmitJobApplication({required this.jobId, required this.userId});
}
