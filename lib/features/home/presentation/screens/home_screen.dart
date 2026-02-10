import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasi_hustle/core/data/datasources/job_data_source.dart';
import 'package:kasi_hustle/features/home/bloc/home_bloc.dart';
import 'package:kasi_hustle/features/home/data/datasources/home_local_data_source.dart';
import 'package:kasi_hustle/features/home/data/repositories/home_repository_impl.dart';
import 'package:kasi_hustle/features/home/domain/models/job.dart';
import 'package:kasi_hustle/features/home/domain/usecases/filter_jobs_by_skill.dart';
import 'package:kasi_hustle/features/home/domain/usecases/get_jobs.dart';
import 'package:kasi_hustle/features/home/domain/usecases/get_recommended_jobs.dart';
import 'package:kasi_hustle/features/home/domain/usecases/get_user_profile.dart';
import 'package:kasi_hustle/features/home/domain/usecases/search_jobs.dart';
import 'package:kasi_hustle/features/home/domain/usecases/submit_application_usecase.dart';
import 'package:kasi_hustle/features/home/presentation/bloc/map/home_map_bloc.dart';
import 'package:kasi_hustle/features/home/presentation/bloc/map/home_map_event.dart';
import 'package:kasi_hustle/features/home/presentation/widgets/home_map_view.dart';
import 'package:kasi_hustle/features/home/presentation/widgets/home_simple_bottom_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ==================== HOME SCREEN ====================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onSearchTap});
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    // Shared data source
    final jobDataSource = JobDataSourceImpl(Supabase.instance.client);
    final localDataSource = HomeLocalDataSourceImpl(jobDataSource);
    final repository = HomeRepositoryImpl(localDataSource);

    // Domain usecases
    final getUserProfile = makeGetUserProfile(repository);
    final getJobs = makeGetJobs(repository);
    final getRecommendedJobs = makeGetRecommendedJobs(repository);
    final searchJobs = makeSearchJobs(repository);
    final filterJobsBySkill = makeFilterJobsBySkill(repository);
    final submitApplicationUseCase = SubmitApplicationUseCase(repository);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HomeBloc(
            getUserProfile: getUserProfile,
            getJobs: getJobs,
            getRecommendedJobs: getRecommendedJobs,
            searchJobs: searchJobs,
            filterJobsBySkill: filterJobsBySkill,
            submitApplicationUseCase: submitApplicationUseCase,
          )..add(LoadHomeData()),
        ),
        BlocProvider(
          create: (context) => HomeMapBloc()..add(InitializeMap(context)),
        ),
      ],
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
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: MultiBlocListener(
        listeners: [
          // Listen to Data (Jobs) -> Update Map Markers & Location
          BlocListener<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state is HomeLoaded) {
                final jobs = state.displayedJobs.cast<Job>();
                final mapBloc = context.read<HomeMapBloc>();

                // 1. Update Map Markers
                mapBloc.add(UpdateMapMarkers(jobs));

                // 2. Trigger initial location update with saved location from profile
                final user = state.user;
                LatLng? savedLocation;
                if (user.latitude != null && user.longitude != null) {
                  savedLocation = LatLng(user.latitude!, user.longitude!);
                }

                mapBloc.add(UpdateUserLocation(savedLocation: savedLocation));
              }
            },
          ),
        ],
        child: Stack(
          children: [
            // 1. Google Map Background
            const HomeMapView(),

            // 2. Simple Bottom Sheet (Top Layer)
            HomeSimpleBottomSheet(
              onFullModeChanged: (isFull) {
                debugPrint('Home Sheet Full Mode: $isFull');
              },
            ),
          ],
        ),
      ),
    );
  }
}
