import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kasi_hustle/core/services/user_profile_service.dart';
import 'package:kasi_hustle/features/auth/bloc/app_bloc.dart';
import 'package:kasi_hustle/features/auth/presentation/login_screen.dart';
import 'package:kasi_hustle/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:kasi_hustle/features/verification/presentation/screens/verification_screen.dart';
import 'package:kasi_hustle/main_layout.dart';
import 'package:kasi_hustle/features/home/presentation/screens/home_screen.dart';
import 'package:kasi_hustle/features/search/presentation/screens/search_screen.dart';
import 'package:kasi_hustle/features/applications/presentation/screens/applications_screen.dart';
import 'package:kasi_hustle/features/applications/presentation/screens/my_applicion_screen.dart';
import 'package:kasi_hustle/features/profile/presentation/screens/profile_screen.dart';
import 'package:kasi_hustle/features/business_home/presentation/screens/business_home_screen.dart';
import 'package:kasi_hustle/features/post_job/presentation/screens/post_job_screen.dart';

/// Route names for easy reference throughout the app
class AppRoutes {
  // Splash
  static const splash = '/splash';

  // Auth routes
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const verification = '/verification';

  // Main app routes
  static const home = '/';
  static const search = '/search';
  static const applications = '/applications';
  static const profile = '/profile';

  // Business routes
  static const businessHome = '/business';
  static const postJob = '/post-job';

  // Test/Demo routes
  static const jobDirectionDemo = '/job-direction-demo';
}

/// Global key for navigation
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouterRefreshStream to listen to AppBloc state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AppState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AppState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Create the router with AppBloc integration
GoRouter createAppRouter(AppBloc appBloc) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(appBloc.stream),

    // Redirect logic for auth based on AppBloc state
    redirect: (context, state) async {
      final appState = appBloc.state;
      final isOnLoginPage = state.matchedLocation == AppRoutes.login;
      final isOnOnboardingPage = state.matchedLocation == AppRoutes.onboarding;
      final isOnVerificationPage =
          state.matchedLocation == AppRoutes.verification;

      if (kDebugMode) {
        print(
          '🔐 Auth check: status=${appState.status}, profileCompleted=${appState.profileCompleted}, location=${state.matchedLocation}',
        );
      }

      // Handle different auth states
      switch (appState.status) {
        case AppStatus.unknown:
        case AppStatus.loading:
          // Still loading, stay where we are
          return AppRoutes.login;

        case AppStatus.unauthenticated:
          // Not logged in - redirect to login unless already there
          if (!isOnLoginPage && !isOnVerificationPage) {
            if (kDebugMode) {
              print('🚫 Not authenticated, redirecting to login');
            }
            return AppRoutes.login;
          }
          return null;

        case AppStatus.authenticated:
          // Logged in - check if profile is complete
          if (!appState.profileCompleted) {
            // Profile incomplete - go to onboarding unless already there
            if (!isOnOnboardingPage) {
              if (kDebugMode) {
                print('🚧 Profile incomplete, redirecting to onboarding');
              }
              // Pass user's current name as extras
              final user = appState.user;
              final queryParams = <String, String>{};
              if (user?.firstName != null) {
                queryParams['firstName'] = user!.firstName;
              }
              if (user?.lastName != null) {
                queryParams['lastName'] = user!.lastName;
              }
              return Uri(
                path: AppRoutes.onboarding,
                queryParameters: queryParams.isNotEmpty ? queryParams : null,
              ).toString();
            }
            return null;
          }

          // Profile complete - redirect to home if on auth pages
          if (isOnLoginPage || isOnOnboardingPage || isOnVerificationPage) {
            final userType = appState.user?.userType ?? 'hustler';
            final destination = userType == 'hustler'
                ? AppRoutes.home
                : AppRoutes.businessHome;
            if (kDebugMode) {
              print(
                '✅ Authenticated with complete profile, redirecting to $destination',
              );
            }
            return destination;
          }
          return null;
      }
    },

    routes: [
      // Auth routes (no shell)
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) {
          // Get name from query parameters (for redirects) or extras (for navigation)
          String? firstName = state.uri.queryParameters['firstName'];
          String? lastName = state.uri.queryParameters['lastName'];

          // If not in query params, check extras (from go/push with extra)
          if (firstName == null && lastName == null) {
            final extra = state.extra;
            if (extra != null && extra is Map) {
              firstName = extra['firstName'] as String?;
              lastName = extra['lastName'] as String?;
            }
          }

          return CustomTransitionPage(
            key: state.pageKey,
            child: OnboardingScreen(
              initialFirstName: firstName,
              initialLastName: lastName,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeInOut,
                    ).animate(animation),
                    child: child,
                  );
                },
            transitionDuration: const Duration(milliseconds: 400),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.verification,
        name: 'verification',
        builder: (context, state) => const VerificationScreen(),
      ),

      // Main app routes with bottom navigation (for hustlers)
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          final isHustler =
              UserProfileService().currentUser?.userType == 'hustler';

          return MainLayout(isHustler: isHustler, child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => NoTransitionPage(
              child: HomeScreen(
                onSearchTap: () => context.go(AppRoutes.search),
              ),
            ),
          ),

          GoRoute(
            path: AppRoutes.search,
            name: 'search',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SearchScreen()),
          ),

          GoRoute(
            path: AppRoutes.applications,
            name: 'applications',
            pageBuilder: (context, state) {
              final isHustler =
                  UserProfileService().currentUser?.userType == 'hustler';
              return NoTransitionPage(
                child: isHustler
                    ? const MyApplicationsScreen()
                    : const ApplicationsScreen(),
              );
            },
          ),

          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),

          // Business routes
          GoRoute(
            path: AppRoutes.businessHome,
            name: 'businessHome',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: BusinessHomeScreen()),
          ),

          GoRoute(
            path: AppRoutes.postJob,
            name: 'postJob',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CreateJobScreen()),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.matchedLocation}')),
    ),
  );
}
