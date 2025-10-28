import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/data/datasources/job_data_source.dart';
import 'package:kasi_hustle/core/theme/app_theme.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/buttons/icon_btn.dart';
import 'package:kasi_hustle/core/widgets/styled_text_input.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/core/widgets/job_card.dart';
import 'package:kasi_hustle/features/search/bloc/search_bloc.dart';
import 'package:kasi_hustle/features/search/data/datasources/search_local_data_source.dart';
import 'package:kasi_hustle/features/search/data/repositories/search_repository_impl.dart';
import 'package:kasi_hustle/features/search/domain/usecases/search_jobs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Shared data source
    final jobDataSource = JobDataSourceImpl(Supabase.instance.client);

    // Data layer
    final localDataSource = SearchLocalDataSourceImpl(jobDataSource);

    // Data repository implementation
    final repository = SearchRepositoryImpl(localDataSource);

    // Domain usecase
    final searchJobs = makeSearchJobs(repository);

    return BlocProvider(
      create: (context) => SearchBloc(searchJobs),
      child: const SearchScreenContent(),
    );
  }
}

class SearchScreenContent extends StatefulWidget {
  const SearchScreenContent({super.key});

  @override
  _SearchScreenContentState createState() => _SearchScreenContentState();
}

class _SearchScreenContentState extends State<SearchScreenContent> {
  final TextEditingController _searchController = TextEditingController();

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
      body: Container(
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
                    text: 'Find Your Next Hustle',
                    style: TextStyles.headlineMedium.copyWith(
                      color: colorScheme.surface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  VSpace.xs,
                  UiText(
                    text: 'Search for jobs that match your skills.',
                    style: TextStyles.bodyLarge.copyWith(
                      color: colorScheme.surface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.lg),
              child: StyledTextInput(
                controller: _searchController,
                autoFocus: true,
                hintText: 'Search by title, skill, or keyword...',
                prefixIcon: Icon(Ionicons.search, color: colorScheme.primary),
                suffixWidget: _searchController.text.isNotEmpty
                    ? IconBtn(
                        Ionicons.close_circle,
                        onPressed: () {
                          _searchController.clear();
                          context.read<SearchBloc>().add(SearchJobsEvent(''));
                        },
                      )
                    : null,
                onChanged: (value) {
                  context.read<SearchBloc>().add(SearchJobsEvent(value));
                },
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
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state is SearchLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is SearchError) {
                      return Center(child: Text(state.message));
                    }
                    if (state is SearchLoaded) {
                      return ListView.builder(
                        padding: EdgeInsets.symmetric(
                          vertical: Insets.lg,
                          horizontal: Insets.lg,
                        ),
                        itemCount: state.results.length,
                        itemBuilder: (context, index) {
                          return JobCard(job: state.results[index]);
                        },
                      );
                    }
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Ionicons.search_outline,
                            size: 60,
                            color: colorScheme.outline,
                          ),
                          VSpace.med,
                          UiText(
                            text: 'Start typing to search for jobs',
                            style: TextStyles.bodyLarge.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
