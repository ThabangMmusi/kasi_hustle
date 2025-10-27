import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasi_hustle/core/theme/app_theme.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/core/widgets/buttons/primary_btn.dart';

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
      Application(
        id: '2',
        jobId: 'job2',
        jobTitle: 'Electrician Needed',
        jobDescription: 'Wiring for a new room.',
        budget: 1500.0,
        location: 'Orlando, Soweto',
        applicantId: 'user1',
        applicantName: 'Thabo Mkhize',
        message: 'I am a certified electrician.',
        status: 'accepted',
        appliedAt: DateTime.now().subtract(const Duration(days: 2)),
        jobOwnerId: 'owner2',
        jobOwnerName: 'Jane Doe',
      ),
      Application(
        id: '3',
        jobId: 'job3',
        jobTitle: 'Gardener Wanted',
        jobDescription: 'General garden maintenance.',
        budget: 200.0,
        location: 'Diepkloof, Soweto',
        applicantId: 'user1',
        applicantName: 'Thabo Mkhize',
        message: 'I love gardening.',
        status: 'rejected',
        appliedAt: DateTime.now().subtract(const Duration(days: 3)),
        jobOwnerId: 'owner3',
        jobOwnerName: 'John Smith',
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

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: theme.colorScheme.surface,
        systemNavigationBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return Scaffold(
      body: BlocBuilder<ApplicationsBloc, ApplicationsState>(
        builder: (context, state) {
          return Container(
            color: AppColors.darkSurface,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(Insets.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VSpace.xxl,
                      UiText(
                        text: 'My Applications',
                        style: TextStyles.headlineMedium.copyWith(
                          color: colorScheme.surface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      VSpace.lg,
                      if (state is ApplicationsLoaded)
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
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                    ),
                    child: Builder(
                      builder: (context) {
                        if (state is ApplicationsLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state is ApplicationsError) {
                          return Center(child: Text(state.message));
                        }

                        if (state is ApplicationsLoaded) {
                          return _buildMyApplicationsList(context, state);
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMyApplicationsList(
    BuildContext context,
    ApplicationsLoaded state,
  ) {
    if (state.myApplications.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off_outlined,
              size: 80,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No applications yet',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start applying to jobs to see them here',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.4),
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
        if (state.pendingApplications.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            'Pending',
            state.pendingApplications.length,
          ),
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
          _buildSectionHeader(
            context,
            'Accepted',
            state.acceptedApplications.length,
          ),
          const SizedBox(height: 12),
          ...state.acceptedApplications.map(
            (app) => ApplicationCard(application: app),
          ),
          const SizedBox(height: 24),
        ],
        if (state.rejectedApplications.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            'Rejected',
            state.rejectedApplications.length,
          ),
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
        color: color.withValues(alpha: 0.2),
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

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: Insets.med),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: Corners.medBorder,
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: Corners.medBorder,
          onTap: () {
            // Navigate to application detail
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: UiText(
                  text: 'Opening application for ${application.jobTitle}',
                ),
                backgroundColor: colorScheme.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(Insets.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            application.jobTitle,
                            style: TextStyles.titleMedium,
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
                    VSpace.sm,
                    Text(
                      application.jobDescription,
                      style: TextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    VSpace.med,
                    Row(
                      children: [
                        Icon(
                          Ionicons.person_outline,
                          color: colorScheme.onSurface.withOpacity(0.5),
                          size: IconSizes.xs,
                        ),
                        HSpace.xs,
                        UiText(
                          text: 'Posted by ${application.jobOwnerName}',
                          style: TextStyles.bodySmall.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        HSpace.lg,
                        Icon(
                          Ionicons.cash_outline,
                          color: colorScheme.primary,
                          size: IconSizes.xs,
                        ),
                        HSpace.xs,
                        UiText(
                          text: 'R${application.budget.toStringAsFixed(0)}',
                          style: TextStyles.bodySmall.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    VSpace.sm,
                    Row(
                      children: [
                        Icon(
                          Ionicons.location_outline,
                          color: colorScheme.onSurface.withOpacity(0.5),
                          size: IconSizes.xs,
                        ),
                        HSpace.xs,
                        UiText(
                          text: application.location,
                          style: TextStyles.bodySmall.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        HSpace.lg,
                        Icon(
                          Ionicons.time_outline,
                          color: colorScheme.onSurface.withOpacity(0.5),
                          size: IconSizes.xs,
                        ),
                        HSpace.xs,
                        UiText(
                          text: _getTimeAgo(application.appliedAt),
                          style: TextStyles.bodySmall.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (application.status == 'pending' && onWithdraw != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    Insets.lg,
                    0,
                    Insets.lg,
                    Insets.lg,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: PrimaryBtn(
                      onPressed: onWithdraw,
                      label: 'Withdraw Application',
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
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
        return Ionicons.checkmark_circle;
      case 'rejected':
        return Ionicons.close_circle;
      default:
        return Ionicons.time;
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
