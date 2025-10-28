import 'package:kasi_hustle/features/home/domain/models/job.dart';
import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final UserProfile user;
  final List<Job> allJobs;
  final List<Job> recommendedJobs;
  final List<Job> displayedJobs;
  final String? selectedSkillFilter;

  HomeLoaded({
    required this.user,
    required this.allJobs,
    required this.recommendedJobs,
    required this.displayedJobs,
    this.selectedSkillFilter,
  });

  HomeLoaded copyWith({
    UserProfile? user,
    List<Job>? allJobs,
    List<Job>? recommendedJobs,
    List<Job>? displayedJobs,
    String? selectedSkillFilter,
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
    );
  }
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
