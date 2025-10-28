part of 'home_bloc.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final UserProfile user;
  final List<Job> allJobs;
  final List<Job> recommendedJobs;
  final List<Job> displayedJobs;
  final String? selectedSkillFilter;
  final List<String> applyingJobIds;

  HomeLoaded({
    required this.user,
    required this.allJobs,
    required this.recommendedJobs,
    required this.displayedJobs,
    this.selectedSkillFilter,
    this.applyingJobIds = const [],
  });

  HomeLoaded copyWith({
    UserProfile? user,
    List<Job>? allJobs,
    List<Job>? recommendedJobs,
    List<Job>? displayedJobs,
    String? selectedSkillFilter,
    List<String>? applyingJobIds,
    bool clearFilter = false,
  }) {
    return HomeLoaded(
      user: user ?? this.user,
      allJobs: allJobs ?? this.allJobs,
      recommendedJobs: recommendedJobs ?? this.recommendedJobs,
      displayedJobs: displayedJobs ?? this.displayedJobs,
      selectedSkillFilter: clearFilter
          ? null
          : (selectedSkillFilter ?? this.selectedSkillFilter),
      applyingJobIds: applyingJobIds ?? this.applyingJobIds,
    );
  }
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
