import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasi_hustle/features/home/domain/models/job.dart';
import 'package:kasi_hustle/features/search/domain/usecases/search_jobs.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchJobs searchJobs;

  SearchBloc(this.searchJobs) : super(SearchInitial()) {
    on<SearchJobsEvent>((event, emit) async {
      if (event.query.isEmpty) {
        emit(SearchInitial());
        return;
      }

      emit(SearchLoading());
      try {
        final results = await searchJobs(event.query);
        emit(SearchLoaded(results));
      } catch (e) {
        emit(SearchError('Failed to search jobs: $e'));
      }
    });
  }
}
