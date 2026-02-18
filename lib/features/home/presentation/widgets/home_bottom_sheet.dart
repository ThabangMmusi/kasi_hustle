import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/buttons/primary_btn.dart';
import 'package:kasi_hustle/core/widgets/job_card.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/features/home/presentation/bloc/home/home_bloc.dart';

class HomeBottomSheet extends StatelessWidget {
  const HomeBottomSheet({
    super.key,
    required this.sheetController,
    required this.sheetPosition,
    required this.snappingEnabled,
    this.maxSheetHeight = 0.92,
    this.triggerHeight = 0.8,
  });

  final DraggableScrollableController sheetController;
  final ValueNotifier<double> sheetPosition;
  final bool snappingEnabled;
  final double maxSheetHeight;
  final double triggerHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final jobs = state is HomeLoaded ? state.displayedJobs : [];
        final bool isLoading = state is HomeLoading;

        if (isLoading) return const SizedBox.shrink();

        return DraggableScrollableSheet(
          controller: sheetController,
          initialChildSize: 0.18,
          minChildSize: 0.18,
          maxChildSize: maxSheetHeight,
          snap: snappingEnabled,
          snapSizes: snappingEnabled ? const [0.5, 0.92] : null,
          builder: (context, scrollController) {
            return ValueListenableBuilder<double>(
              valueListenable: sheetPosition,
              builder: (context, sheetPos, _) {
                final expandProgress =
                    ((sheetPos - triggerHeight) /
                            (maxSheetHeight - triggerHeight))
                        .clamp(0.0, 1.0);
                final currentRadius = 24 * (1 - expandProgress);

                return Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(currentRadius),
                      topRight: Radius.circular(currentRadius),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: CustomScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      // 1. Handle Bar (Now INSIDE the scroll view so it catches drags)
                      SliverToBoxAdapter(
                        child: Opacity(
                          opacity: (1 - expandProgress).clamp(0.0, 1.0),
                          child: Container(
                            height:
                                20 * (1 - expandProgress), // Collapse height
                            margin: EdgeInsets.only(
                              top: Insets.med * (1 - expandProgress),
                            ),
                            child: Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 2. Main Content Wrapper
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            if (expandProgress < 1.0)
                              VSpace.med
                            else
                              VSpace.xxl,
                            Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(24.0),
                                  topRight: Radius.circular(24.0),
                                ),
                              ),
                              child: Column(
                                children: [
                                  VSpace.lg,
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
                          ],
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
                          child: Container(
                            color: colorScheme.surface,
                            child: Center(
                              child: _buildError(context, state.message),
                            ),
                          ),
                        )
                      else
                        const SliverToBoxAdapter(child: SizedBox.shrink()),

                      // 4. Bottom Padding
                      SliverToBoxAdapter(
                        child: Container(
                          height: 80,
                          color: colorScheme.surface,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
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
                      : colorScheme.outline.withValues(alpha: 77),
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
              ).colorScheme.onSurface.withValues(alpha: 153),
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
          style: TextStyles.bodyLarge.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
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
