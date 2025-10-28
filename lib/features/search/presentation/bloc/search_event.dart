// Events for Search feature
abstract class SearchEvent {}

class SearchJobs extends SearchEvent {
  final String query;
  SearchJobs(this.query);
}
