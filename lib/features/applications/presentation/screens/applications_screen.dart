import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ==================== MODELS ====================

class Application {
  final String id;
  final String jobId;
  final String jobTitle;
  final String jobDescription;
  final double budget;
  final String location;
  final String applicantId;
  final String applicantName;
  final String message;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime appliedAt;
  final String jobOwnerId;
  final String jobOwnerName;

  Application({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.jobDescription,
    required this.budget,
    required this.location,
    required this.applicantId,
    required this.applicantName,
    required this.message,
    required this.status,
    required this.appliedAt,
    required this.jobOwnerId,
    required this.jobOwnerName,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'],
      jobId: json['job_id'],
      jobTitle: json['job_title'] ?? '',
      jobDescription: json['job_description'] ?? '',
      budget: json['budget']?.toDouble() ?? 0.0,
      location: json['location'] ?? '',
      applicantId: json['applicant_id'],
      applicantName: json['applicant_name'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 'pending',
      appliedAt: DateTime.parse(
        json['applied_at'] ?? DateTime.now().toIso8601String(),
      ),
      jobOwnerId: json['job_owner_id'] ?? '',
      jobOwnerName: json['job_owner_name'] ?? '',
    );
  }
}

class JobPost {
  final String id;
  final String title;
  final String description;
  final double budget;
  final String location;
  final String status;
  final DateTime createdAt;
  final int applicationsCount;

  JobPost({
    required this.id,
    required this.title,
    required this.description,
    required this.budget,
    required this.location,
    required this.status,
    required this.createdAt,
    required this.applicationsCount,
  });

  factory JobPost.fromJson(Map<String, dynamic> json) {
    return JobPost(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      budget: json['budget']?.toDouble() ?? 0.0,
      location: json['location'] ?? '',
      status: json['status'] ?? 'open',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      applicationsCount: json['applications_count'] ?? 0,
    );
  }
}

// ==================== BLOC EVENTS ====================

abstract class ApplicationsEvent {}

class LoadApplications extends ApplicationsEvent {}

class ChangeTab extends ApplicationsEvent {
  final int tabIndex;
  ChangeTab(this.tabIndex);
}

class WithdrawApplication extends ApplicationsEvent {
  final String applicationId;
  WithdrawApplication(this.applicationId);
}

class CloseJobPost extends ApplicationsEvent {
  final String jobId;
  CloseJobPost(this.jobId);
}

// ==================== BLOC STATES ====================

abstract class ApplicationsState {}

class ApplicationsInitial extends ApplicationsState {}

class ApplicationsLoading extends ApplicationsState {}

class ApplicationsLoaded extends ApplicationsState {
  final List<Application> myApplications;
  final List<JobPost> myJobPosts;
  final int currentTab;

  ApplicationsLoaded({
    required this.myApplications,
    required this.myJobPosts,
    this.currentTab = 0,
  });

  ApplicationsLoaded copyWith({
    List<Application>? myApplications,
    List<JobPost>? myJobPosts,
    int? currentTab,
  }) {
    return ApplicationsLoaded(
      myApplications: myApplications ?? this.myApplications,
      myJobPosts: myJobPosts ?? this.myJobPosts,
      currentTab: currentTab ?? this.currentTab,
    );
  }

  List<Application> get pendingApplications =>
      myApplications.where((app) => app.status == 'pending').toList();

  List<Application> get acceptedApplications =>
      myApplications.where((app) => app.status == 'accepted').toList();

  List<Application> get rejectedApplications =>
      myApplications.where((app) => app.status == 'rejected').toList();
}

class ApplicationsError extends ApplicationsState {
  final String message;
  ApplicationsError(this.message);
}

// ==================== BLOC ====================

class ApplicationsBloc extends Bloc<ApplicationsEvent, ApplicationsState> {
  ApplicationsBloc() : super(ApplicationsInitial()) {
    on<LoadApplications>(_onLoadApplications);
    on<ChangeTab>(_onChangeTab);
    on<WithdrawApplication>(_onWithdrawApplication);
    on<CloseJobPost>(_onCloseJobPost);
  }

  Future<void> _onLoadApplications(
    LoadApplications event,
    Emitter<ApplicationsState> emit,
  ) async {
    emit(ApplicationsLoading());
    try {
      // Simulate fetching from Supabase
      await Future.delayed(const Duration(seconds: 1));

      final myApplications = _getMockApplications();
      final myJobPosts = _getMockJobPosts();

      emit(
        ApplicationsLoaded(
          myApplications: myApplications,
          myJobPosts: myJobPosts,
        ),
      );
    } catch (e) {
      emit(ApplicationsError('Failed to load applications: $e'));
    }
  }

  void _onChangeTab(ChangeTab event, Emitter<ApplicationsState> emit) {
    if (state is ApplicationsLoaded) {
      final currentState = state as ApplicationsLoaded;
      emit(currentState.copyWith(currentTab: event.tabIndex));
    }
  }

  Future<void> _onWithdrawApplication(
    WithdrawApplication event,
    Emitter<ApplicationsState> emit,
  ) async {
    if (state is ApplicationsLoaded) {
      final currentState = state as ApplicationsLoaded;

      try {
        await Future.delayed(const Duration(milliseconds: 500));

        final updatedApplications = currentState.myApplications
            .where((app) => app.id != event.applicationId)
            .toList();

        emit(currentState.copyWith(myApplications: updatedApplications));
      } catch (e) {
        emit(ApplicationsError('Failed to withdraw application: $e'));
      }
    }
  }

  Future<void> _onCloseJobPost(
    CloseJobPost event,
    Emitter<ApplicationsState> emit,
  ) async {
    if (state is ApplicationsLoaded) {
      final currentState = state as ApplicationsLoaded;

      try {
        await Future.delayed(const Duration(milliseconds: 500));

        final updatedJobPosts = currentState.myJobPosts.map((job) {
          if (job.id == event.jobId) {
            return JobPost(
              id: job.id,
              title: job.title,
              description: job.description,
              budget: job.budget,
              location: job.location,
              status: 'closed',
              createdAt: job.createdAt,
              applicationsCount: job.applicationsCount,
            );
          }
          return job;
        }).toList();

        emit(currentState.copyWith(myJobPosts: updatedJobPosts));
      } catch (e) {
        emit(ApplicationsError('Failed to close job: $e'));
      }
    }
  }

  List<Application> _getMockApplications() {
    return [
      Application(
        id: '1',
        jobId: 'job1',
        jobTitle: 'Plumbing Repair Needed',
        jobDescription: 'Kitchen sink leaking, need urgent fix',
        budget: 350.0,
        location: 'Soweto, 2.3 km away',
        applicantId: 'user1',
        applicantName: 'Thabo Mkhize',
        message:
            'Hi! I have 5 years experience with plumbing. Available today.',
        status: 'pending',
        appliedAt: DateTime.now().subtract(const Duration(hours: 3)),
        jobOwnerId: 'owner1',
        jobOwnerName: 'Sarah Nkosi',
      ),
      Application(
        id: '2',
        jobId: 'job2',
        jobTitle: 'Electrical Installation',
        jobDescription: 'Need to install ceiling lights in 3 rooms',
        budget: 800.0,
        location: 'Alexandra, 4.1 km away',
        applicantId: 'user1',
        applicantName: 'Thabo Mkhize',
        message: 'I can do this job. Licensed electrician with certificate.',
        status: 'accepted',
        appliedAt: DateTime.now().subtract(const Duration(days: 1)),
        jobOwnerId: 'owner2',
        jobOwnerName: 'John Modise',
      ),
      Application(
        id: '3',
        jobId: 'job3',
        jobTitle: 'Carpentry Work - Door Repair',
        jobDescription: 'Front door needs fixing, handle broken',
        budget: 450.0,
        location: 'Diepkloof, 1.8 km away',
        applicantId: 'user1',
        applicantName: 'Thabo Mkhize',
        message: 'Can come tomorrow morning to check the door.',
        status: 'rejected',
        appliedAt: DateTime.now().subtract(const Duration(days: 2)),
        jobOwnerId: 'owner3',
        jobOwnerName: 'Mary Sithole',
      ),
      Application(
        id: '4',
        jobId: 'job4',
        jobTitle: 'Garden Maintenance',
        jobDescription: 'Regular garden cleaning needed',
        budget: 250.0,
        location: 'Orlando East, 3.5 km away',
        applicantId: 'user1',
        applicantName: 'Thabo Mkhize',
        message: 'Available weekly for garden maintenance.',
        status: 'pending',
        appliedAt: DateTime.now().subtract(const Duration(hours: 8)),
        jobOwnerId: 'owner4',
        jobOwnerName: 'Peter Dlamini',
      ),
    ];
  }

  List<JobPost> _getMockJobPosts() {
    return [
      JobPost(
        id: 'post1',
        title: 'Looking for Painter',
        description: 'Need interior walls painted',
        budget: 1200.0,
        location: 'Soweto',
        status: 'open',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        applicationsCount: 5,
      ),
      JobPost(
        id: 'post2',
        title: 'Tiling Work Needed',
        description: 'Bathroom floor tiling',
        budget: 900.0,
        location: 'Alexandra',
        status: 'open',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        applicationsCount: 2,
      ),
    ];
  }
}

// ==================== APPLICATIONS SCREEN ====================

class ApplicationsScreen extends StatelessWidget {
  const ApplicationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ApplicationsBloc()..add(LoadApplications()),
      child: const ApplicationsScreenContent(),
    );
  }
}

class ApplicationsScreenContent extends StatelessWidget {
  const ApplicationsScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<ApplicationsBloc, ApplicationsState>(
        builder: (context, state) {
          if (state is ApplicationsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD700)),
            );
          }

          if (state is ApplicationsError) {
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
                      context.read<ApplicationsBloc>().add(LoadApplications());
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

          if (state is ApplicationsLoaded) {
            return DefaultTabController(
              length: 2,
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      floating: true,
                      pinned: true,
                      backgroundColor: Colors.black,
                      elevation: 0,
                      title: const Text(
                        'My Jobs',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(50),
                        child: Container(
                          color: Colors.black,
                          child: TabBar(
                            indicatorColor: const Color(0xFFFFD700),
                            indicatorWeight: 3,
                            labelColor: const Color(0xFFFFD700),
                            unselectedLabelColor: Colors.white.withOpacity(0.6),
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            tabs: const [
                              Tab(text: 'My Applications'),
                              Tab(text: 'My Posts'),
                            ],
                            onTap: (index) {
                              context.read<ApplicationsBloc>().add(
                                ChangeTab(index),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  children: [
                    // My Applications Tab
                    _buildMyApplicationsTab(context, state),
                    // My Posts Tab
                    _buildMyPostsTab(context, state),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMyApplicationsTab(
    BuildContext context,
    ApplicationsLoaded state,
  ) {
    if (state.myApplications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No applications yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start applying to jobs to see them here',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats Row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.pending_outlined,
                value: '${state.pendingApplications.length}',
                label: 'Pending',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle_outline,
                value: '${state.acceptedApplications.length}',
                label: 'Accepted',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.cancel_outlined,
                value: '${state.rejectedApplications.length}',
                label: 'Rejected',
                color: Colors.red,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Pending Applications
        if (state.pendingApplications.isNotEmpty) ...[
          _buildSectionHeader('Pending', state.pendingApplications.length),
          const SizedBox(height: 12),
          ...state.pendingApplications.map(
            (app) => ApplicationCard(
              application: app,
              onWithdraw: () {
                _showWithdrawDialog(context, app.id);
              },
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Accepted Applications
        if (state.acceptedApplications.isNotEmpty) ...[
          _buildSectionHeader('Accepted', state.acceptedApplications.length),
          const SizedBox(height: 12),
          ...state.acceptedApplications.map(
            (app) => ApplicationCard(application: app),
          ),
          const SizedBox(height: 24),
        ],

        // Rejected Applications
        if (state.rejectedApplications.isNotEmpty) ...[
          _buildSectionHeader('Rejected', state.rejectedApplications.length),
          const SizedBox(height: 12),
          ...state.rejectedApplications.map(
            (app) => ApplicationCard(application: app),
          ),
        ],
      ],
    );
  }

  Widget _buildMyPostsTab(BuildContext context, ApplicationsLoaded state) {
    if (state.myJobPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.post_add_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No job posts yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Post your first job to find hustlers',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.myJobPosts.length,
      itemBuilder: (context, index) {
        final job = state.myJobPosts[index];
        return JobPostCard(
          job: job,
          onClose: () {
            _showCloseJobDialog(context, job.id);
          },
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _showWithdrawDialog(BuildContext context, String applicationId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Withdraw Application',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to withdraw this application?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ApplicationsBloc>().add(
                WithdrawApplication(applicationId),
              );
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Application withdrawn'),
                  backgroundColor: Color(0xFFFFD700),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  void _showCloseJobDialog(BuildContext context, String jobId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Close Job Post',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to close this job posting?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ApplicationsBloc>().add(CloseJobPost(jobId));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Job post closed'),
                  backgroundColor: Color(0xFFFFD700),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
            ),
            child: const Text('Close Job'),
          ),
        ],
      ),
    );
  }
}

// ==================== APPLICATION CARD ====================

class ApplicationCard extends StatelessWidget {
  final Application application;
  final VoidCallback? onWithdraw;

  const ApplicationCard({Key? key, required this.application, this.onWithdraw})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor().withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        application.jobTitle,
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
                        color: _getStatusColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getStatusColor()),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(),
                            color: _getStatusColor(),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            application.status.toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  application.jobDescription,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: Colors.white.withOpacity(0.5),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Posted by ${application.jobOwnerName}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.attach_money,
                      color: Color(0xFFFFD700),
                      size: 16,
                    ),
                    Text(
                      'R${application.budget.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.white.withOpacity(0.5),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      application.location,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      color: Colors.white.withOpacity(0.5),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getTimeAgo(application.appliedAt),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (application.message.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.message_outlined,
                    color: Colors.white.withOpacity(0.5),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      application.message,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (application.status == 'pending' && onWithdraw != null)
                    TextButton(
                      onPressed: onWithdraw,
                      child: const Text(
                        'Withdraw',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (application.status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon() {
    switch (application.status) {
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return 'Applied ${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return 'Applied ${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return 'Applied ${difference.inMinutes}m ago';
    } else {
      return 'Applied just now';
    }
  }
}

// ==================== JOB POST CARD ====================

class JobPostCard extends StatelessWidget {
  final JobPost job;
  final VoidCallback onClose;

  const JobPostCard({Key? key, required this.job, required this.onClose})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOpen = job.status == 'open';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOpen
              ? const Color(0xFFFFD700).withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    color: isOpen
                        ? const Color(0xFFFFD700).withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isOpen ? const Color(0xFFFFD700) : Colors.grey,
                    ),
                  ),
                  child: Text(
                    job.status.toUpperCase(),
                    style: TextStyle(
                      color: isOpen ? const Color(0xFFFFD700) : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              job.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        color: Color(0xFFFFD700),
                        size: 16,
                      ),
                      Text(
                        'R${job.budget.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.location_on_outlined,
                  color: Colors.white.withOpacity(0.5),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  job.location,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: job.applicationsCount > 0
                        ? Colors.green.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        color: job.applicationsCount > 0
                            ? Colors.green
                            : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${job.applicationsCount} ${job.applicationsCount == 1 ? 'Application' : 'Applications'}',
                        style: TextStyle(
                          color: job.applicationsCount > 0
                              ? Colors.green
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.access_time,
                  color: Colors.white.withOpacity(0.5),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _getTimeAgo(job.createdAt),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (isOpen) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('View applications'),
                            backgroundColor: Color(0xFFFFD700),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('View Applications'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFFD700),
                        side: const BorderSide(color: Color(0xFFFFD700)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onClose,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Close Job'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.8),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return 'Posted ${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return 'Posted ${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return 'Posted ${difference.inMinutes}m ago';
    } else {
      return 'Posted just now';
    }
  }
}
