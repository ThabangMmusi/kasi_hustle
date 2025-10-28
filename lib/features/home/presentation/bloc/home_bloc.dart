import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasi_hustle/core/services/user_profile_service.dart';
import 'package:kasi_hustle/features/home/domain/models/job.dart';
import 'package:kasi_hustle/features/home/presentation/bloc/home_event.dart';
import 'package:kasi_hustle/features/home/presentation/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserProfileService _userProfileService;

  HomeBloc({required UserProfileService userProfileService})
    : _userProfileService = userProfileService,
      super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
    on<SearchJobs>(_onSearchJobs);
    on<FilterBySkill>(_onFilterBySkill);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      // Get current user from UserProfileService
      final user = _userProfileService.currentUser;
      if (user == null) {
        emit(HomeError('User not logged in'));
        return;
      }

      final allJobs = _getMockJobs();
      final recommended = _getRecommendedJobs(allJobs, user.primarySkills);
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
        await Future.delayed(const Duration(milliseconds: 500));
        final allJobs = _getMockJobs();
        final recommended = _getRecommendedJobs(
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

  void _onSearchJobs(SearchJobs event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final filtered = currentState.allJobs.where((job) {
        return job.title.toLowerCase().contains(event.query.toLowerCase()) ||
            job.description.toLowerCase().contains(event.query.toLowerCase());
      }).toList();

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
        final filtered = currentState.allJobs.where((job) {
          return job.title.toLowerCase().contains(event.skill.toLowerCase()) ||
              job.description.toLowerCase().contains(event.skill.toLowerCase());
        }).toList();

        emit(
          currentState.copyWith(
            displayedJobs: filtered,
            selectedSkillFilter: event.skill,
          ),
        );
      }
    }
  }

  List<Job> _getMockJobs() {
    return [
      Job(
        id: '1',
        title: 'Plumbing Repair Needed',
        description: 'Kitchen sink leaking, need urgent fix',
        location: 'Soweto, 2.3 km away',
        latitude: -26.2478,
        longitude: 27.8546,
        budget: 350.0,
        createdBy: 'user2',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'open',
      ),
      Job(
        id: '2',
        title: 'Electrical Installation',
        description: 'Need to install ceiling lights in 3 rooms',
        location: 'Alexandra, 4.1 km away',
        latitude: -26.1022,
        longitude: 28.0993,
        budget: 800.0,
        createdBy: 'user3',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        status: 'open',
      ),
      Job(
        id: '3',
        title: 'Carpentry Work - Door Repair',
        description: 'Front door needs fixing, handle broken',
        location: 'Diepkloof, 1.8 km away',
        latitude: -26.2481,
        longitude: 27.8614,
        budget: 450.0,
        createdBy: 'user4',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        status: 'open',
      ),
      Job(
        id: '4',
        title: 'Garden Cleaning',
        description: 'Need someone to clean and maintain garden',
        location: 'Orlando East, 3.5 km away',
        latitude: -26.2345,
        longitude: 27.8912,
        budget: 250.0,
        createdBy: 'user5',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: 'open',
      ),
      Job(
        id: '5',
        title: 'Painting Interior Walls',
        description: '2 bedroom house needs fresh paint',
        location: 'Moroka, 5.2 km away',
        latitude: -26.2678,
        longitude: 27.8734,
        budget: 1200.0,
        createdBy: 'user6',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: 'open',
      ),
    ];
  }

  List<Job> _getRecommendedJobs(List<Job> allJobs, List<String> userSkills) {
    return allJobs.where((job) {
      return userSkills.any(
        (skill) =>
            job.title.toLowerCase().contains(skill.toLowerCase()) ||
            job.description.toLowerCase().contains(skill.toLowerCase()),
      );
    }).toList();
  }
}
