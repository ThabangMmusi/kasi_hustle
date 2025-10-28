import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasi_hustle/core/theme/app_theme.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/widgets/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/application.dart';
import '../../domain/usecases/application_usecases.dart';
import '../../data/repositories/application_repository_impl.dart';
import '../../../home/domain/models/job.dart';
import '../widgets/job_direction_bottom_sheet.dart';
import '../../../auth/bloc/app_bloc.dart';
import '../bloc/bloc.dart';
import '../widgets/messages_bottom_sheet.dart';

// ==================== UI SCREEN ====================

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseClient = Supabase.instance.client;
    final repository = ApplicationRepositoryImpl(supabaseClient);

    final getMyApplicationsUseCase = GetMyApplicationsUseCase(repository);
    final withdrawApplicationUseCase = WithdrawApplicationUseCase(repository);

    return BlocProvider(
      create: (context) => MyApplicationsBloc(
        getMyApplicationsUseCase: getMyApplicationsUseCase,
        withdrawApplicationUseCase: withdrawApplicationUseCase,
      )..add(LoadMyApplications()),
      child: const MyApplicationsScreenContent(),
    );
  }
}

class MyApplicationsScreenContent extends StatelessWidget {
  const MyApplicationsScreenContent({super.key});

  @override
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
      body: BlocBuilder<MyApplicationsBloc, MyApplicationsState>(
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
                      if (state is MyApplicationsLoaded)
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
                        if (state is MyApplicationsLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state is MyApplicationsError) {
                          return Center(child: Text(state.message));
                        }

                        if (state is MyApplicationsLoaded) {
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
    MyApplicationsLoaded state,
  ) {
    if (state.applications.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off_outlined,
              size: 80,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No applications yet',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start applying to jobs to see them here',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
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
              context.read<MyApplicationsBloc>().add(
                WithdrawMyApplication(applicationId),
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

// ==================== REUSABLE CARD WIDGET ====================

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
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
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
                            color: _getStatusColor().withValues(alpha: 0.2),
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
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    VSpace.med,
                    Row(
                      children: [
                        Icon(
                          Ionicons.person_outline,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          size: IconSizes.xs,
                        ),
                        HSpace.xs,
                        UiText(
                          text: 'Posted by ${application.jobOwnerName}',
                          style: TextStyles.bodySmall.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
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
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          size: IconSizes.xs,
                        ),
                        HSpace.xs,
                        UiText(
                          text: application.location,
                          style: TextStyles.bodySmall.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        HSpace.lg,
                        Icon(
                          Ionicons.time_outline,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          size: IconSizes.xs,
                        ),
                        HSpace.xs,
                        UiText(
                          text: _getTimeAgo(application.appliedAt),
                          style: TextStyles.bodySmall.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
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
              if (application.status == 'accepted')
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    Insets.lg,
                    0,
                    Insets.lg,
                    Insets.lg,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: PrimaryBtn(
                          onPressed: () {
                            // Get user location from AppBloc
                            final appState = context.read<AppBloc>().state;
                            LatLng? userLocation;

                            if (appState.status == AppStatus.authenticated &&
                                appState.user != null &&
                                appState.user!.latitude != null &&
                                appState.user!.longitude != null) {
                              userLocation = LatLng(
                                appState.user!.latitude!,
                                appState.user!.longitude!,
                              );
                            }

                            // Convert Application to Job for direction sheet
                            final job = Job(
                              id: application.jobId,
                              title: application.jobTitle,
                              description: application.jobDescription,
                              location: application.location,
                              latitude: application.latitude,
                              longitude: application.longitude,
                              budget: application.budget,
                              createdBy: application.jobOwnerId,
                              createdAt: application.appliedAt,
                              status: 'open',
                            );

                            // Show job direction bottom sheet with user location
                            JobDirectionBottomSheet.show(
                              context,
                              job,
                              userLocation: userLocation,
                            );
                          },
                          icon: Ionicons.location_outline,
                          label: 'Direction',
                        ),
                      ),
                      HSpace.med,
                      Expanded(
                        child: SecondaryBtn(
                          onPressed: () {
                            MessagesBottomSheet.show(context, application);
                          },
                          icon: Ionicons.chatbubble_outline,
                          label: 'Message',
                        ),
                      ),
                    ],
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
