import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/buttons/primary_btn.dart';
import 'package:kasi_hustle/core/widgets/job_card.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/features/home/bloc/home_bloc.dart';

class HomeSimpleBottomSheet extends StatefulWidget {
  const HomeSimpleBottomSheet({super.key, this.onFullModeChanged});

  final ValueChanged<bool>? onFullModeChanged;

  @override
  State<HomeSimpleBottomSheet> createState() => _HomeSimpleBottomSheetState();
}

class _HomeSimpleBottomSheetState extends State<HomeSimpleBottomSheet> {
  bool _isFullMode = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final jobs = state is HomeLoaded ? state.displayedJobs : [];
        final bool isLoading = state is HomeLoading;

        if (isLoading) return const SizedBox.shrink();

        return NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            // Trigger "Full Mode" logic when we are nearly at the top
            final isAtTop = notification.extent >= 0.99;
            if (isAtTop != _isFullMode) {
              setState(() {
                _isFullMode = isAtTop;
              });
              widget.onFullModeChanged?.call(isAtTop);
            }
            return false;
          },
          child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.5,
            maxChildSize: 1.0,
            snap: true,
            snapSizes: const [0.5, 1.0],
            builder: (context, scrollController) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(_isFullMode ? 0 : 24),
                    topRight: Radius.circular(_isFullMode ? 0 : 24),
                  ),
                  boxShadow: [
                    if (!_isFullMode)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                  ],
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // 1. Pinned Header (Handle Bar)
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _BottomSheetHeaderDelegate(
                        isFullMode: _isFullMode,
                        colorScheme: colorScheme,
                      ),
                    ),

                    // 2. Main Content
                    SliverSafeArea(
                      top: _isFullMode,
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          children: [
                            _buildSkillsFilter(context, state),
                            if (state is HomeLoaded &&
                                state.recommendedJobs.isNotEmpty &&
                                state.selectedSkillFilter == null)
                              _buildRecommendedJobs(
                                context,
                                state.recommendedJobs,
                              ),
                            _buildAllJobsHeader(context, jobs.length),
                          ],
                        ),
                      ),
                    ),

                    // 3. Jobs List
                    if (state is HomeLoaded)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return Container(
                              color: colorScheme.surface,
                              padding: EdgeInsets.only(bottom: Insets.med),
                              child: JobCard(job: jobs[index]),
                            );
                          }, childCount: jobs.length),
                        ),
                      )
                    else if (state is HomeError)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: _buildError(context, state.message),
                        ),
                      ),

                    // Bottom Padding
                    SliverToBoxAdapter(child: VSpace.xxl),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSkillsFilter(BuildContext context, HomeState state) {
    if (state is! HomeLoaded) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Insets.lg),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: state.user.primarySkills.map((skill) {
            final isSelected = state.selectedSkillFilter == skill;
            return Padding(
              padding: EdgeInsets.only(right: Insets.sm),
              child: FilterChip(
                label: Text(skill),
                selected: isSelected,
                onSelected: (_) {
                  context.read<HomeBloc>().add(FilterBySkill(skill));
                },
                backgroundColor: colorScheme.surfaceContainer,
                selectedColor: colorScheme.primary,
                checkmarkColor: colorScheme.onPrimary,
                labelStyle: TextStyles.labelLarge.copyWith(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                ),
                side: BorderSide(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRecommendedJobs(BuildContext context, List<dynamic> jobs) {
    return Padding(
      padding: EdgeInsets.all(Insets.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Ionicons.star,
                color: Theme.of(context).colorScheme.primary,
                size: IconSizes.sm,
              ),
              HSpace.sm,
              UiText(text: 'Recommended for You', style: TextStyles.titleLarge),
            ],
          ),
          VSpace.med,
          ...jobs.take(2).map((job) => JobCard(job: job)),
        ],
      ),
    );
  }

  Widget _buildAllJobsHeader(BuildContext context, int count) {
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, Insets.lg, Insets.lg, Insets.med),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          UiText(text: 'All Jobs', style: TextStyles.titleLarge),
          UiText(
            text: '$count available',
            style: TextStyles.bodyMedium.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Ionicons.warning_outline,
          color: Theme.of(context).colorScheme.error,
          size: 48,
        ),
        VSpace.lg,
        UiText(
          text: message,
          style: TextStyles.bodyLarge,
          textAlign: TextAlign.center,
        ),
        VSpace.lg,
        PrimaryBtn(
          onPressed: () {
            context.read<HomeBloc>().add(LoadHomeData());
          },
          label: 'Retry',
        ),
      ],
    );
  }
}

class _BottomSheetHeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isFullMode;
  final ColorScheme colorScheme;

  _BottomSheetHeaderDelegate({
    required this.isFullMode,
    required this.colorScheme,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isFullMode) ...[
            VSpace.med,
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
          // No bottom VSpace here to keep chips close
        ],
      ),
    );
  }

  @override
  double get maxExtent => isFullMode ? 32 : 28;

  @override
  double get minExtent => isFullMode ? 32 : 28;

  @override
  bool shouldRebuild(covariant _BottomSheetHeaderDelegate oldDelegate) {
    return oldDelegate.isFullMode != isFullMode ||
        oldDelegate.colorScheme != colorScheme;
  }
}
