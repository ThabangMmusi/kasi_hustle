import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/services/user_profile_service.dart';
import 'package:kasi_hustle/core/theme/app_theme.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/buttons/primary_btn.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/features/home/bloc/home_bloc.dart';
import 'package:kasi_hustle/features/home/domain/models/job.dart';

class JobDetailsBottomSheet extends StatelessWidget {
  final Job job;
  final HomeBloc homeBloc;

  const JobDetailsBottomSheet({
    super.key,
    required this.job,
    required this.homeBloc,
  });

  static void show(BuildContext context, Job job) {
    final homeBloc = context.read<HomeBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => JobDetailsBottomSheet(job: job, homeBloc: homeBloc),
    );
  }

  @override
  Widget build(BuildContext context) {
    return JobDetailsBottomSheetContent(job: job, homeBloc: homeBloc);
  }
}

class JobDetailsBottomSheetContent extends StatefulWidget {
  final Job job;
  final HomeBloc homeBloc;

  const JobDetailsBottomSheetContent({
    super.key,
    required this.job,
    required this.homeBloc,
  });

  @override
  State<JobDetailsBottomSheetContent> createState() =>
      _JobDetailsBottomSheetContentState();
}

class _JobDetailsBottomSheetContentState
    extends State<JobDetailsBottomSheetContent> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;

    return BlocProvider<HomeBloc>.value(
      value: widget.homeBloc,
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeLoaded &&
              !state.applyingJobIds.contains(widget.job.id)) {
            // Job has been removed from applyingJobIds, meaning submission completed
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: UiText(
                  text: 'Application submitted successfully! 🎉',
                  style: TextStyles.bodyMedium.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
                backgroundColor: colorScheme.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is HomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: UiText(
                  text: state.message,
                  style: TextStyles.bodyMedium.copyWith(
                    color: colorScheme.onError,
                  ),
                ),
                backgroundColor: colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Container(
          constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.9),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: Insets.med),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: Padding(
                    padding: EdgeInsets.all(Insets.xl),
                    child: BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, homeState) {
                        final isApplying =
                            homeState is HomeLoaded &&
                            homeState.applyingJobIds.contains(widget.job.id);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Job Title
                            UiText(
                              text: widget.job.title,
                              style: TextStyles.headlineSmall,
                            ),
                            VSpace.sm,

                            // Budget and Required Skills Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Budget
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Ionicons.cash_outline,
                                        color: colorScheme.primary,
                                        size: IconSizes.sm,
                                      ),
                                      HSpace.sm,
                                      Expanded(
                                        child: UiText(
                                          text:
                                              'R${widget.job.budget.toStringAsFixed(0)}',
                                          style: TextStyles.titleLarge.copyWith(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                HSpace.lg,
                                // Required Skills Badge
                                if (widget.job.requiredSkills.isNotEmpty)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Insets.med,
                                      vertical: Insets.sm,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success,
                                      borderRadius: Corners.fullBorder,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Ionicons.cog_outline,
                                          color: colorScheme.onPrimary,
                                          size: IconSizes.xs,
                                        ),
                                        HSpace.xs,
                                        UiText(
                                          text: widget.job.status.toUpperCase(),
                                          style: TextStyles.labelSmall.copyWith(
                                            color: colorScheme.onPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            VSpace.lg,

                            // Location & Time
                            Row(
                              children: [
                                Icon(
                                  Ionicons.location_outline,
                                  color: colorScheme.onSurfaceVariant,
                                  size: IconSizes.xs,
                                ),
                                HSpace.xs,
                                UiText(
                                  text: widget.job.location,
                                  style: TextStyles.bodyMedium,
                                ),
                                HSpace.lg,
                                Icon(
                                  Ionicons.time_outline,
                                  color: colorScheme.onSurfaceVariant,
                                  size: IconSizes.xs,
                                ),
                                HSpace.xs,
                                UiText(
                                  text: _getTimeAgo(widget.job.createdAt),
                                  style: TextStyles.bodyMedium,
                                ),
                              ],
                            ),
                            VSpace.lg,

                            // Description
                            UiText(
                              text: 'Description',
                              style: TextStyles.titleMedium,
                            ),
                            VSpace.sm,
                            UiText(
                              text: widget.job.description,
                              style: TextStyles.bodyMedium.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                            VSpace.lg,

                            // Required Skills
                            if (widget.job.requiredSkills.isNotEmpty) ...[
                              UiText(
                                text: 'Required Skills',
                                style: TextStyles.titleMedium,
                              ),
                              VSpace.sm,
                              Wrap(
                                spacing: Insets.sm,
                                runSpacing: Insets.sm,
                                children: widget.job.requiredSkills.map((
                                  skill,
                                ) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Insets.sm,
                                      vertical: Insets.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.secondary.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: Corners.fullBorder,
                                      border: Border.all(
                                        color: colorScheme.secondary,
                                        width: 1,
                                      ),
                                    ),
                                    child: UiText(
                                      text: skill,
                                      style: TextStyles.labelMedium.copyWith(
                                        color: colorScheme.secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              VSpace.lg,
                            ],

                            // Job Images (if available)
                            if (widget.job.imageUrls.isNotEmpty) ...[
                              VSpace.lg,
                              UiText(
                                text: 'Images (${widget.job.imageUrls.length})',
                                style: TextStyles.titleMedium,
                              ),
                              VSpace.sm,
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.job.imageUrls.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        right:
                                            index <
                                                widget.job.imageUrls.length - 1
                                            ? Insets.sm
                                            : 0,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            barrierColor:
                                                AppColors.kasiCharcoal,
                                            builder: (context) => Dialog(
                                              backgroundColor:
                                                  Colors.transparent,
                                              insetPadding: EdgeInsets.zero,
                                              child: Container(
                                                width: MediaQuery.of(
                                                  context,
                                                ).size.width,
                                                height: MediaQuery.of(
                                                  context,
                                                ).size.height,
                                                color: AppColors.kasiCharcoal,
                                                child: Stack(
                                                  children: [
                                                    // Scrollable list of images
                                                    Positioned.fill(
                                                      child: PageView.builder(
                                                        itemCount: widget
                                                            .job
                                                            .imageUrls
                                                            .length,
                                                        controller:
                                                            PageController(
                                                              initialPage:
                                                                  index,
                                                            ),
                                                        itemBuilder:
                                                            (
                                                              context,
                                                              pageIndex,
                                                            ) {
                                                              return Center(
                                                                child: Image.network(
                                                                  widget
                                                                      .job
                                                                      .imageUrls[pageIndex],
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                              );
                                                            },
                                                      ),
                                                    ),
                                                    // Close button at bottom
                                                    Positioned(
                                                      bottom: 40,
                                                      left: 0,
                                                      right: 0,
                                                      child: Center(
                                                        child: IconButton(
                                                          icon: Icon(
                                                            Ionicons
                                                                .close_circle,
                                                            color: AppColors
                                                                .kasiOffWhite,
                                                            size: 48,
                                                          ),
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                context,
                                                              ).pop(),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius: Corners.smBorder,
                                          child: Image.network(
                                            widget.job.imageUrls[index],
                                            width: 160,
                                            height: 120,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    width: 160,
                                                    height: 120,
                                                    color: colorScheme
                                                        .surfaceContainer,
                                                    child: Icon(
                                                      Ionicons.image_outline,
                                                      color: colorScheme
                                                          .onSurfaceVariant,
                                                      size: 32,
                                                    ),
                                                  );
                                                },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                            VSpace.xl,

                            // Apply button (always show)
                            SizedBox(
                              width: double.infinity,
                              child: PrimaryBtn(
                                onPressed: isApplying
                                    ? null
                                    : () {
                                        final userId =
                                            UserProfileService()
                                                .currentUser
                                                ?.id ??
                                            'unknown';
                                        context.read<HomeBloc>().add(
                                          SubmitJobApplication(
                                            jobId: widget.job.id,
                                            userId: userId,
                                          ),
                                        );
                                      },
                                label: isApplying ? 'Applying...' : 'Apply Now',
                              ),
                            ),
                          ],
                        );
                      },
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
