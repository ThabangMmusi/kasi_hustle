import 'package:kasi_hustle/features/home/domain/models/job.dart';

// States for Search feature
abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

class SearchLoaded extends SearchState {
  final List<Job> results;
  SearchLoaded(this.results);
}
