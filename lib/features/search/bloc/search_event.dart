part of 'search_bloc.dart';

abstract class SearchEvent {}

class SearchJobsEvent extends SearchEvent {
  final String query;
  SearchJobsEvent(this.query);
}
