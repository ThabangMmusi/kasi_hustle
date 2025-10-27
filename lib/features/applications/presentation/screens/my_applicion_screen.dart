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
}

// ==================== BLOC EVENTS ====================

abstract class ApplicationsEvent {}

class LoadApplications extends ApplicationsEvent {}

class WithdrawApplication extends ApplicationsEvent {
  final String applicationId;
  WithdrawApplication(this.applicationId);
}

// ==================== BLOC STATES ====================

abstract class ApplicationsState {}

class ApplicationsInitial extends ApplicationsState {}

class ApplicationsLoading extends ApplicationsState {}

class ApplicationsLoaded extends ApplicationsState {
  final List<Application> myApplications;

  ApplicationsLoaded({required this.myApplications});

  ApplicationsLoaded copyWith({List<Application>? myApplications}) {
    return ApplicationsLoaded(
      myApplications: myApplications ?? this.myApplications,
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
    on<WithdrawApplication>(_onWithdrawApplication);
  }

  Future<void> _onLoadApplications(
    LoadApplications event,
    Emitter<ApplicationsState> emit,
  ) async {
    emit(ApplicationsLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      final myApplications = _getMockApplications();
      emit(ApplicationsLoaded(myApplications: myApplications));
    } catch (e) {
      emit(ApplicationsError('Failed to load applications: $e'));
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
    ];
  }
}

// ==================== APPLICATIONS SCREEN ====================

class ApplicationsScreen extends StatelessWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ApplicationsBloc()..add(LoadApplications()),
      child: const ApplicationsScreenContent(),
    );
  }
}

class ApplicationsScreenContent extends StatelessWidget {
  const ApplicationsScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Applications')),
      body: BlocBuilder<ApplicationsBloc, ApplicationsState>(
        builder: (context, state) {
          if (state is ApplicationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ApplicationsError) {
            return Center(child: Text(state.message));
          }

          if (state is ApplicationsLoaded) {
            return _buildMyApplicationsTab(context, state);
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
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No applications yet',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start applying to jobs to see them here',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
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
        if (state.acceptedApplications.isNotEmpty) ...[
          _buildSectionHeader('Accepted', state.acceptedApplications.length),
          const SizedBox(height: 12),
          ...state.acceptedApplications.map(
            (app) => ApplicationCard(application: app),
          ),
          const SizedBox(height: 24),
        ],
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
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
              color: Colors.white.withValues(alpha: 0.6),
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
            color: const Color(0xFFFFD700).withValues(alpha: 0.2),
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
}

class ApplicationCard extends StatelessWidget {
  final Application application;
  final VoidCallback? onWithdraw;

  const ApplicationCard({
    super.key,
    required this.application,
    this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor().withValues(alpha: 0.3)),
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
                        color: _getStatusColor().withValues(alpha: 0.2),
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
                      Icons.person_outline,
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Posted by ${application.jobOwnerName}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
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
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      application.location,
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
                      _getTimeAgo(application.appliedAt),
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
          if (application.message.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.message_outlined,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      application.message,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
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
