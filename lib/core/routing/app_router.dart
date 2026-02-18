import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';
import 'package:kasi_hustle/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:kasi_hustle/features/profile/presentation/bloc/profile_event.dart';
import 'package:kasi_hustle/features/profile/presentation/screens/profile_screen.dart';
import 'package:kasi_hustle/features/profile/presentation/screens/edit_names_screen.dart';
import 'package:kasi_hustle/features/profile/presentation/screens/edit_contacts_screen.dart';
import 'package:kasi_hustle/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:kasi_hustle/features/wallet/presentation/screens/edit_bank_details_screen.dart';
import 'package:kasi_hustle/features/menu/presentation/screens/menu_screen.dart';
import 'package:kasi_hustle/features/settings/presentation/screens/settings_screen.dart';
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
  static const menu = '/menu';
  static const settings = '/settings';
  static const editNames = '/edit-names';
  static const editContacts = '/edit-contacts';

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

      ShellRoute(
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state, child) => BlocProvider(
          create: (context) =>
              ProfileBloc(userProfileService: UserProfileService())
                ..add(LoadProfile()),
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit-names',
                name: 'editNames',
                builder: (context, state) {
                  final profile = state.extra as UserProfile;
                  return EditNamesScreen(profile: profile);
                },
              ),
              GoRoute(
                path: 'edit-contacts',
                name: 'editContacts',
                builder: (context, state) {
                  final profile = state.extra as UserProfile;
                  return EditContactsScreen(profile: profile);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/wallet',
            name: 'wallet',
            builder: (context, state) => const WalletScreen(),
          ),
          GoRoute(
            path: '/edit-bank-details',
            name: 'editBankDetails',
            builder: (context, state) {
              final profile = state.extra as UserProfile;
              return EditBankDetailsScreen(profile: profile);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),

      // Main app routes with stateful shell (indexed stack for state preservation)
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state, navigationShell) {
          final isHustler =
              UserProfileService().currentUser?.userType == 'hustler';
          return MainLayout(
            isHustler: isHustler,
            navigationShell: navigationShell,
          );
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
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
              // Branch-specific business route if needed, but keeping it flat for now
              GoRoute(
                path: AppRoutes.businessHome,
                name: 'businessHome',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: BusinessHomeScreen()),
              ),
            ],
          ),

          // Branch 1: Search / Post Job
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.search,
                name: 'search',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SearchScreen()),
              ),
              GoRoute(
                path: AppRoutes.postJob,
                name: 'postJob',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CreateJobScreen()),
              ),
            ],
          ),

          // Branch 2: Applications
          StatefulShellBranch(
            routes: [
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
            ],
          ),

          // Branch 3: Menu
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.menu,
                name: 'menu',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const MenuScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.matchedLocation}')),
    ),
  );
}
