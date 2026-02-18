import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/widgets/widgets.dart';
import 'package:kasi_hustle/core/utils/ui_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/application_repository_impl.dart';
import '../../domain/models/application.dart';
import '../../domain/usecases/application_usecases.dart';
import '../bloc/bloc.dart';

// ==================== APPLICATIONS SCREEN ====================

class ApplicationsScreen extends StatelessWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseClient = Supabase.instance.client;
    final repository = ApplicationRepositoryImpl(supabaseClient);
    final getReceivedApplicationsUseCase = GetReceivedApplicationsUseCase(
      repository,
    );
    final updateApplicationStatusUseCase = UpdateApplicationStatusUseCase(
      repository,
    );

    return BlocProvider(
      create: (context) => ReceivedApplicationsBloc(
        getReceivedApplicationsUseCase: getReceivedApplicationsUseCase,
        updateApplicationStatusUseCase: updateApplicationStatusUseCase,
      )..add(LoadReceivedApplications()),
      child: const ApplicationsScreenContent(),
    );
  }
}

class ApplicationsScreenContent extends StatelessWidget {
  const ApplicationsScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // SystemChrome.setSystemUIOverlayStyle(
    //   SystemUiOverlayStyle(
    //     statusBarColor: Colors.transparent,
    //     statusBarIconBrightness: Brightness.light,
    //     systemNavigationBarColor: theme.colorScheme.surface,
    //     systemNavigationBarIconBrightness: theme.brightness == Brightness.dark
    //         ? Brightness.light
    //         : Brightness.dark,
    //   ),
    // );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: UiText(
          text: 'My Applications',
          style: TextStyles.headlineSmall.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: false,
      ),
      body: BlocBuilder<ReceivedApplicationsBloc, ReceivedApplicationsState>(
        builder: (context, state) {
          if (state is ReceivedApplicationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReceivedApplicationsError) {
            return Center(child: Text(state.message));
          }

          if (state is ReceivedApplicationsLoaded) {
            final tabs = <Tab>[];
            final tabViews = <Widget>[];

            if (state.pendingApplications.isNotEmpty) {
              tabs.add(
                Tab(text: 'Pending (${state.pendingApplications.length})'),
              );
              tabViews.add(
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: state.pendingApplications
                      .map(
                        (app) => ApplicationCard(
                          application: app,
                          onWithdraw: () {
                            _showRejectBottomSheet(context, app.id);
                          },
                        ),
                      )
                      .toList(),
                ),
              );
            }

            if (state.acceptedApplications.isNotEmpty) {
              tabs.add(
                Tab(text: 'Accepted (${state.acceptedApplications.length})'),
              );
              tabViews.add(
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: state.acceptedApplications
                      .map((app) => ApplicationCard(application: app))
                      .toList(),
                ),
              );
            }

            if (state.rejectedApplications.isNotEmpty) {
              tabs.add(
                Tab(text: 'Rejected (${state.rejectedApplications.length})'),
              );
              tabViews.add(
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: state.rejectedApplications
                      .map((app) => ApplicationCard(application: app))
                      .toList(),
                ),
              );
            }

            if (tabs.isEmpty) {
              return _buildEmptyState(context);
            }

            return DefaultTabController(
              length: tabs.length,
              child: Column(
                children: [
                  TabBar(
                    tabs: tabs,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: colorScheme.primary,
                    unselectedLabelColor: colorScheme.onSurface.withValues(
                      alpha: 0.6,
                    ),
                    indicatorColor: colorScheme.primary,
                    dividerColor: Colors.transparent,
                  ),
                  Expanded(child: TabBarView(children: tabViews)),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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

  void _showRejectBottomSheet(BuildContext context, String applicationId) {
    UiUtils.showGlobalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: Insets.lg,
          ).copyWith(bottom: bottomPadding + Insets.med),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.all(Radius.circular(24)),
          ),
          padding: EdgeInsets.all(Insets.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              VSpace.lg,
              UiText(
                text: 'Reject Application',
                style: TextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              VSpace.med,
              UiText(
                text: 'Are you sure you want to reject this application?',
                style: TextStyles.bodyLarge.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              VSpace.xl,
              PrimaryBtn(
                label: 'Reject Application',
                onPressed: () {
                  context.read<ReceivedApplicationsBloc>().add(
                    RejectApplicationEvent(applicationId),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Application rejected'),
                      backgroundColor: Color(0xFFFFD700),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                ),
              ),
              VSpace.med,
              TextBtn('Cancel', onPressed: () => Navigator.pop(context)),
              VSpace.med,
            ],
          ),
        );
      },
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
                          text: 'Applicant: ${application.applicantName}',
                          style: TextStyles.bodySmall.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
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
                        Spacer(),
                        Row(
                          children: [
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
                      label: 'Reject Application',
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
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
