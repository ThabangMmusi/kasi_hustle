abstract class HomeEvent {}

class LoadHomeData extends HomeEvent {}

class RefreshHomeData extends HomeEvent {}

class SearchJobs extends HomeEvent {
  final String query;
  SearchJobs(this.query);
}

class FilterBySkill extends HomeEvent {
  final String skill;
  FilterBySkill(this.skill);
}
