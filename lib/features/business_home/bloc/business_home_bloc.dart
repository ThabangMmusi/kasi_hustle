import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasi_hustle/features/business_home/domain/usecases/get_posted_jobs.dart';
import 'package:kasi_hustle/features/home/domain/models/job.dart';

part 'business_home_event.dart';
part 'business_home_state.dart';

class BusinessHomeBloc extends Bloc<BusinessHomeEvent, BusinessHomeState> {
  final GetPostedJobs getPostedJobs;

  BusinessHomeBloc(this.getPostedJobs) : super(BusinessHomeLoading()) {
    on<LoadPostedJobs>((event, emit) async {
      emit(BusinessHomeLoading());
      try {
        final jobs = await getPostedJobs();
        emit(BusinessHomeLoaded(jobs));
      } catch (e) {
        emit(BusinessHomeError(e.toString()));
      }
    });
  }
}
