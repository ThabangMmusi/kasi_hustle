import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasi_hustle/features/home/domain/models/job.dart';
import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';
import 'package:kasi_hustle/features/home/domain/usecases/filter_jobs_by_skill.dart';
import 'package:kasi_hustle/features/home/domain/usecases/get_jobs.dart';
import 'package:kasi_hustle/features/home/domain/usecases/get_recommended_jobs.dart';
import 'package:kasi_hustle/features/home/domain/usecases/get_user_profile.dart';
import 'package:kasi_hustle/features/home/domain/usecases/search_jobs.dart';
import 'package:kasi_hustle/features/home/domain/usecases/submit_application_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetUserProfile getUserProfile;
  final GetJobs getJobs;
  final GetRecommendedJobs getRecommendedJobs;
  final SearchJobs searchJobs;
  final FilterJobsBySkill filterJobsBySkill;
  final SubmitApplicationUseCase submitApplicationUseCase;

  HomeBloc({
    required this.getUserProfile,
    required this.getJobs,
    required this.getRecommendedJobs,
    required this.searchJobs,
    required this.filterJobsBySkill,
    required this.submitApplicationUseCase,
  }) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
    on<SearchJobsEvent>(_onSearchJobs);
    on<FilterBySkill>(_onFilterBySkill);
    on<SubmitJobApplication>(_onSubmitJobApplication);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final user = await getUserProfile();
      final allJobs = await getJobs();
      final recommended = getRecommendedJobs(allJobs, user.primarySkills);

      emit(
        HomeLoaded(
          user: user,
          allJobs: allJobs,
          recommendedJobs: recommended,
          displayedJobs: allJobs,
        ),
      );
    } catch (e) {
      emit(HomeError('Failed to load data: $e'));
    }
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      try {
        final allJobs = await getJobs();
        final recommended = getRecommendedJobs(
          allJobs,
          currentState.user.primarySkills,
        );

        emit(
          currentState.copyWith(
            allJobs: allJobs,
            recommendedJobs: recommended,
            displayedJobs: allJobs,
          ),
        );
      } catch (e) {
        // Keep current state on error
      }
    }
  }

  void _onSearchJobs(SearchJobsEvent event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final filtered = searchJobs(currentState.allJobs, event.query);
      emit(currentState.copyWith(displayedJobs: filtered));
    }
  }

  void _onFilterBySkill(FilterBySkill event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;

      if (currentState.selectedSkillFilter == event.skill) {
        // Remove filter
        emit(
          currentState.copyWith(
            displayedJobs: currentState.allJobs,
            clearFilter: true,
          ),
        );
      } else {
        // Apply filter
        final filtered = filterJobsBySkill(currentState.allJobs, event.skill);

        emit(
          currentState.copyWith(
            displayedJobs: filtered,
            selectedSkillFilter: event.skill,
          ),
        );
      }
    }
  }

  Future<void> _onSubmitJobApplication(
    SubmitJobApplication event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;

      // Add job ID to applying list
      final updatedApplyingIds = [...currentState.applyingJobIds, event.jobId];
      emit(currentState.copyWith(applyingJobIds: updatedApplyingIds));

      try {
        // Submit application
        await submitApplicationUseCase(
          jobId: event.jobId,
          userId: event.userId,
        );

        // Remove job from jobs list
        final updatedAllJobs = currentState.allJobs
            .where((job) => job.id != event.jobId)
            .toList();
        final updatedDisplayedJobs = currentState.displayedJobs
            .where((job) => job.id != event.jobId)
            .toList();
        final updatedRecommendedJobs = currentState.recommendedJobs
            .where((job) => job.id != event.jobId)
            .toList();

        // Remove from applying list
        final finalApplyingIds = updatedApplyingIds
            .where((id) => id != event.jobId)
            .toList();

        emit(
          currentState.copyWith(
            allJobs: updatedAllJobs,
            displayedJobs: updatedDisplayedJobs,
            recommendedJobs: updatedRecommendedJobs,
            applyingJobIds: finalApplyingIds,
          ),
        );
      } catch (e) {
        // Remove from applying list on error
        final finalApplyingIds = updatedApplyingIds
            .where((id) => id != event.jobId)
            .toList();

        emit(currentState.copyWith(applyingJobIds: finalApplyingIds));

        // Re-emit error or handle appropriately
        emit(HomeError('Failed to submit application: $e'));
      }
    }
  }
}
