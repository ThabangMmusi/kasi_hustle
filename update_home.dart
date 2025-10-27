import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ==================== MODELS ====================

class Job {
  final String id;
  final String title;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final double budget;
  final String createdBy;
  final DateTime createdAt;
  final String status;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.budget,
    required this.createdBy,
    required this.createdAt,
    required this.status,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      budget: json['budget']?.toDouble() ?? 0.0,
      createdBy: json['created_by'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      status: json['status'] ?? 'open',
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final List<String> skills;
  final double rating;
  final int totalReviews;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.skills,
    required this.rating,
    required this.totalReviews,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'] ?? 'Hustler',
      email: json['email'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      rating: json['rating']?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
    );
  }
}

// ==================== BLOC EVENTS ====================

abstract class HomeEvent {}

class LoadHomeData extends HomeEvent {}

class RefreshHomeData extends HomeEvent {}

class SearchJobs extends HomeEvent {
  final String query;
  SearchJobs(this.query);
}

class FilterBySkill extends HomeEvent {
  final String skill;
  FilterBySkill(this.skill);
}

// ==================== BLOC STATES ====================

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

// ==================== BLOC ====================

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
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
      // Simulate fetching from Supabase
      await Future.delayed(const Duration(seconds: 1));

      final user = UserProfile(
        id: '1',
        name: 'Thabo Mkhize',
        email: 'thabo@example.com',
        skills: ['Plumbing', 'Electrical', 'Carpentry'],
        rating: 4.5,
        totalReviews: 23,
      );

      final allJobs = _getMockJobs();
      final recommended = _getRecommendedJobs(allJobs, user.skills);

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
          currentState.user.skills,
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

// ==================== HOME SCREEN ====================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(LoadHomeData()),
      child: const HomeScreenContent(),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD700)),
            );
          }

          if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HomeBloc>().add(LoadHomeData());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is HomeLoaded) {
            return RefreshIndicator(
              color: const Color(0xFFFFD700),
              backgroundColor: Colors.black,
              onRefresh: () async {
                context.read<HomeBloc>().add(RefreshHomeData());
              },
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    backgroundColor: Colors.black,
                    elevation: 0,
                    title: Row(
                      children: [
                        const Text(
                          'KASI',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'HUSTLE',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  // Greeting
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${state.user.name.split(' ')[0]}! 👋',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ready to hustle today?',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFFFFD700,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search jobs...',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFFFFD700),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      context.read<HomeBloc>().add(
                                        SearchJobs(''),
                                      );
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                          onChanged: (value) {
                            context.read<HomeBloc>().add(SearchJobs(value));
                          },
                        ),
                      ),
                    ),
                  ),

                  // Skills Filter
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: state.user.skills.map((skill) {
                            final isSelected =
                                state.selectedSkillFilter == skill;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: Text(skill),
                                selected: isSelected,
                                onSelected: (_) {
                                  context.read<HomeBloc>().add(
                                    FilterBySkill(skill),
                                  );
                                },
                                backgroundColor: const Color(0xFF1A1A1A),
                                selectedColor: const Color(0xFFFFD700),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                side: BorderSide(
                                  color: isSelected
                                      ? const Color(0xFFFFD700)
                                      : Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),

                  // Recommended Jobs Section
                  if (state.recommendedJobs.isNotEmpty &&
                      state.selectedSkillFilter == null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Color(0xFFFFD700),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Recommended for You',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...state.recommendedJobs
                                .take(2)
                                .map((job) => JobCard(job: job)),
                          ],
                        ),
                      ),
                    ),

                  // All Jobs Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'All Jobs',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${state.displayedJobs.length} available',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Jobs List
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return JobCard(job: state.displayedJobs[index]);
                      }, childCount: state.displayedJobs.length),
                    ),
                  ),

                  // Bottom Padding
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ==================== JOB CARD WIDGET ====================

class JobCard extends StatelessWidget {
  final Job job;

  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Navigate to job detail
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening ${job.title}'),
                backgroundColor: const Color(0xFFFFD700),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'R${job.budget.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  job.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.location,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getTimeAgo(job.createdAt),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
