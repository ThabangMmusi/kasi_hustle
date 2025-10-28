import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasi_hustle/core/data/datasources/job_data_source.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/features/business_home/bloc/business_home_bloc.dart';
import 'package:kasi_hustle/features/business_home/data/datasources/business_home_local_data_source.dart';
import 'package:kasi_hustle/features/business_home/data/repositories/business_home_repository_impl.dart';
import 'package:kasi_hustle/features/business_home/domain/usecases/get_posted_jobs.dart';
import 'package:kasi_hustle/features/business_home/presentation/widgets/posted_jobs_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BusinessHomeScreen extends StatelessWidget {
  const BusinessHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Shared data source
    final jobDataSource = JobDataSourceImpl(Supabase.instance.client);

    // Data layer
    final localDataSource = BusinessHomeLocalDataSourceImpl(jobDataSource);

    // Data repository implementation
    final repository = BusinessHomeRepositoryImpl(localDataSource);

    // Domain usecase
    final getPostedJobs = makeGetPostedJobs(repository);

    return BlocProvider(
      create: (context) =>
          BusinessHomeBloc(getPostedJobs)..add(LoadPostedJobs()),
      child: const BusinessHomeScreenContent(),
    );
  }
}

class BusinessHomeScreenContent extends StatelessWidget {
  const BusinessHomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: UiText(text: 'My Job Posts', style: TextStyles.titleLarge),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: BlocBuilder<BusinessHomeBloc, BusinessHomeState>(
        builder: (context, state) {
          if (state is BusinessHomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BusinessHomeError) {
            return Center(child: Text(state.message));
          }
          if (state is BusinessHomeLoaded) {
            return PostedJobsList(postedJobs: state.postedJobs);
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to post job screen
        },
        label: const UiText(text: 'Post a Job'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
