import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasi_hustle/features/home/domain/models/job.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<SearchJobs>((event, emit) async {
      emit(SearchLoading());
      await Future.delayed(const Duration(seconds: 1));
      if (event.query.isEmpty) {
        emit(SearchInitial());
      } else {
        // Dummy data - keep same behaviour as before
        emit(
          SearchLoaded(
            List.generate(
              5,
              (index) => Job(
                id: index.toString(),
                title: 'Job ${index + 1}',
                description:
                    'This is a dummy job description for job ${index + 1}',
                location: 'Soweto',
                latitude: -26.2682,
                longitude: 27.8536,
                budget: 500.0 + (index * 100),
                createdBy: 'user_id',
                createdAt: DateTime.now(),
                status: 'open',
              ),
            ),
          ),
        );
      }
    });
  }
}
