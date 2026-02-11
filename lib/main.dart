import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:kasi_hustle/core/routing/app_router.dart';
import 'package:kasi_hustle/core/services/map_cache_service.dart';
import 'package:kasi_hustle/core/theme/app_theme.dart';
import 'package:kasi_hustle/core/config/env_config.dart';
import 'package:kasi_hustle/core/services/user_profile_service.dart';
import 'package:kasi_hustle/features/auth/bloc/app_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kasi_hustle/core/services/connectivity_service.dart';
import 'package:kasi_hustle/core/bloc/network/network_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Enable Edge-to-Edge for transparent system bars
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      statusBarColor: Colors.transparent,
    ),
  );
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialize Google Maps with Android renderer
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
  }

  // Initialize environment variables
  await EnvConfig.initialize();

  // Initialize Supabase with deep link configuration
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
    // Deep link configuration for OAuth callbacks
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
  );

  runApp(const MyApp());

  // Pre-cache user's township area in background
  _preCacheUserArea();
}

Future<void> _preCacheUserArea() async {
  try {
    // Wait a bit for app to initialize
    await Future.delayed(Duration(seconds: 5));

    debugPrint('🗺️ Starting background map cache...');

    // Load existing home location
    final cacheService = MapCacheService();
    await cacheService.loadHomeLocation();

    if (cacheService.homeLocation != null) {
      debugPrint('✅ Using existing cached home location');
      return;
    }

    // Get user's location
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint('⚠️ Location permission not granted, skipping pre-cache');
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    final userLocation = LatLng(position.latitude, position.longitude);

    // Cache 10km radius
    await cacheService.downloadMapArea(userLocation, radiusKm: 10);

    debugPrint('🎉 User township area pre-cached in background!');
  } catch (e) {
    debugPrint('⚠️ Could not pre-cache area: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final connectivityService = ConnectivityService();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              NetworkBloc(connectivityService)..add(NetworkObserve()),
        ),
        BlocProvider(
          create: (context) =>
              AppBloc(userProfileService: UserProfileService()),
        ),
      ],
      child: Builder(
        builder: (context) {
          // Get the AppBloc to use in router
          final appBloc = context.read<AppBloc>();

          return MaterialApp.router(
            title: 'Kasi Hustle',
            theme: KasiTheme.lightTheme(),
            routerConfig: createAppRouter(appBloc),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
