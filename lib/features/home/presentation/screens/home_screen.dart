import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/data/datasources/job_data_source.dart';
import 'package:kasi_hustle/core/theme/app_theme.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/buttons/primary_btn.dart';
import 'package:kasi_hustle/core/widgets/styled_load_spinner.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/features/home/bloc/home_bloc.dart';
import 'package:kasi_hustle/features/home/data/datasources/home_local_data_source.dart';
import 'package:kasi_hustle/features/home/data/repositories/home_repository_impl.dart';
import 'package:kasi_hustle/features/home/domain/usecases/filter_jobs_by_skill.dart';
import 'package:kasi_hustle/features/home/domain/usecases/get_jobs.dart';
import 'package:kasi_hustle/features/home/domain/usecases/get_recommended_jobs.dart';
import 'package:kasi_hustle/features/home/domain/usecases/get_user_profile.dart';
import 'package:kasi_hustle/features/home/domain/usecases/search_jobs.dart';
import 'package:kasi_hustle/features/home/domain/usecases/submit_application_usecase.dart';
import 'package:kasi_hustle/core/widgets/job_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ==================== HOME SCREEN ====================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onSearchTap});
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    // Shared data source
    final jobDataSource = JobDataSourceImpl(Supabase.instance.client);

    // Data layer
    final localDataSource = HomeLocalDataSourceImpl(jobDataSource);

    // Data repository implementation
    final repository = HomeRepositoryImpl(localDataSource);

    // Domain usecases
    final getUserProfile = makeGetUserProfile(repository);
    final getJobs = makeGetJobs(repository);
    final getRecommendedJobs = makeGetRecommendedJobs(repository);
    final searchJobs = makeSearchJobs(repository);
    final filterJobsBySkill = makeFilterJobsBySkill(repository);

    // Application submission - handled in home feature
    final submitApplicationUseCase = SubmitApplicationUseCase(repository);

    return BlocProvider(
      create: (context) => HomeBloc(
        getUserProfile: getUserProfile,
        getJobs: getJobs,
        getRecommendedJobs: getRecommendedJobs,
        searchJobs: searchJobs,
        filterJobsBySkill: filterJobsBySkill,
        submitApplicationUseCase: submitApplicationUseCase,
      )..add(LoadHomeData()),
      child: HomeScreenContent(onSearchTap: onSearchTap),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key, this.onSearchTap});
  final VoidCallback? onSearchTap;

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarElevated = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final bool needsElevation = _scrollController.offset > 0;
    if (needsElevation != _isAppBarElevated) {
      setState(() {
        _isAppBarElevated = needsElevation;
      });
    }
  }

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
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Container(
            color: AppColors.darkSurface,
            child: RefreshIndicator(
              color: colorScheme.primary,
              backgroundColor: colorScheme.surface,
              onRefresh: () async {
                context.read<HomeBloc>().add(RefreshHomeData());
              },
              child: Column(
                children: [
                  // Greeting
                  Padding(
                    padding: EdgeInsets.all(Insets.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        VSpace.xxl,
                        Builder(
                          builder: (_) {
                            final hour = DateTime.now().hour;
                            final greeting = hour >= 5 && hour < 12
                                ? 'Good morning! 👋'
                                : hour >= 12 && hour < 17
                                ? 'Good day! 👋'
                                : 'Good evening! 👋';
                            return UiText(
                              text: greeting,
                              style: TextStyles.headlineMedium.copyWith(
                                color: colorScheme.surface,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        VSpace.xs,
                        UiText(
                          text: 'Are you ready to hustle today?',
                          style: TextStyles.bodyLarge.copyWith(
                            color: colorScheme.surface.withValues(alpha: 179),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search Bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                    child: GestureDetector(
                      onTap: widget.onSearchTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 14.0,
                        ),
                        decoration: BoxDecoration(
                          color: theme.inputDecorationTheme.fillColor,
                          borderRadius: BorderRadius.circular(28.0),
                        ),
                        child: Row(
                          children: [
                            Icon(Ionicons.search, color: colorScheme.primary),
                            HSpace.med,
                            UiText(
                              text: 'Search jobs...',
                              style: TextStyles.bodyMedium.copyWith(
                                color: colorScheme.onSurfaceVariant.withAlpha(
                                  178,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  VSpace.lg,

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0),
                        ),
                      ),
                      child: state is HomeLoaded
                          ? CustomScrollView(
                              controller: _scrollController,
                              slivers: [
                                // // App Bar
                                // SliverAppBar(
                                //   floating: true,
                                //   pinned: true,
                                //   backgroundColor: _isAppBarElevated
                                //       ? colorScheme.surface
                                //       : colorScheme.surfaceContainer,
                                //   elevation: 0,
                                //   title: Row(
                                //     children: [
                                //       UiText(text: 'KASI', style: TextStyles.headlineSmall),
                                //       HSpace.xs,
                                //       UiText(
                                //         text: 'HUSTLE',
                                //         style: TextStyles.headlineSmall.copyWith(
                                //           color: colorScheme.primary,
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                //   actions: [
                                //     IconBtn(Ionicons.notifications_outline, onPressed: () {}),
                                //   ],
                                // ),

                                // Top Padding
                                SliverToBoxAdapter(child: VSpace.lg),

                                // Skills Filter
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Insets.lg,
                                    ),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: state.user.primarySkills.map((
                                          skill,
                                        ) {
                                          final isSelected =
                                              state.selectedSkillFilter ==
                                              skill;
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              right: Insets.sm,
                                            ),
                                            child: FilterChip(
                                              label: Text(skill),
                                              selected: isSelected,
                                              onSelected: (_) {
                                                context.read<HomeBloc>().add(
                                                  FilterBySkill(skill),
                                                );
                                              },
                                              backgroundColor:
                                                  colorScheme.surfaceContainer,
                                              selectedColor:
                                                  colorScheme.primary,
                                              checkmarkColor:
                                                  colorScheme.onPrimary,
                                              labelStyle: TextStyles.labelLarge
                                                  .copyWith(
                                                    color: isSelected
                                                        ? colorScheme.onPrimary
                                                        : colorScheme.onSurface,
                                                  ),
                                              side: BorderSide(
                                                color: isSelected
                                                    ? colorScheme.primary
                                                    : colorScheme.outline
                                                          .withValues(
                                                            alpha: 77,
                                                          ),
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
                                      padding: EdgeInsets.all(Insets.lg),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Ionicons.star,
                                                color: colorScheme.primary,
                                                size: IconSizes.sm,
                                              ),
                                              HSpace.sm,
                                              UiText(
                                                text: 'Recommended for You',
                                                style: TextStyles.titleLarge,
                                              ),
                                            ],
                                          ),
                                          VSpace.med,
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
                                    padding: EdgeInsets.fromLTRB(
                                      Insets.lg,
                                      Insets.lg,
                                      Insets.lg,
                                      Insets.med,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        UiText(
                                          text: 'All Jobs',
                                          style: TextStyles.titleLarge,
                                        ),
                                        UiText(
                                          text:
                                              '${state.displayedJobs.length} available',
                                          style: TextStyles.bodyMedium.copyWith(
                                            color: colorScheme.onSurface
                                                .withValues(alpha: 153),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Jobs List
                                SliverPadding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Insets.lg,
                                  ),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate((
                                      context,
                                      index,
                                    ) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          bottom: Insets.med,
                                        ),
                                        child: JobCard(
                                          job: state.displayedJobs[index],
                                        ),
                                      );
                                    }, childCount: state.displayedJobs.length),
                                  ),
                                ),

                                // Bottom Padding
                                SliverToBoxAdapter(child: VSpace.xl),
                              ],
                            )
                          : state is HomeError
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Ionicons.warning_outline,
                                    color: colorScheme.error,
                                    size: 48,
                                  ),
                                  VSpace.lg,
                                  UiText(
                                    text: state.message,
                                    style: TextStyles.bodyLarge.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  VSpace.lg,
                                  PrimaryBtn(
                                    onPressed: () {
                                      context.read<HomeBloc>().add(
                                        LoadHomeData(),
                                      );
                                    },
                                    label: 'Retry',
                                  ),
                                ],
                              ),
                            )
                          : const Center(child: StyledLoadSpinner()),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
