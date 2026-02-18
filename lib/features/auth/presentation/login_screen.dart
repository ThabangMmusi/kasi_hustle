import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/core/routing/app_router.dart';
import 'package:kasi_hustle/features/auth/bloc/auth_bloc.dart';
import 'package:kasi_hustle/features/auth/domain/repositories/auth_repository.dart';
import 'package:kasi_hustle/features/auth/domain/usecases/check_auth_status.dart';
import 'package:kasi_hustle/features/auth/domain/usecases/send_magic_link.dart';
import 'package:kasi_hustle/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:kasi_hustle/features/auth/presentation/widgets/email_form.dart';
import 'package:kasi_hustle/features/auth/presentation/widgets/login_background.dart';
import 'package:kasi_hustle/features/auth/presentation/widgets/login_bottom_sheet.dart';
import 'package:kasi_hustle/features/auth/presentation/widgets/login_options.dart';
import 'package:kasi_hustle/features/auth/presentation/widgets/magic_link_dialog.dart';

// ==================== LOGIN SCREEN ====================

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AuthRepositoryImpl();
    final signInWithGoogle = makeSignInWithGoogle(repository);
    final sendMagicLink = makeSendMagicLink(repository);
    final checkAuthStatus = makeCheckAuthStatus(repository);

    return BlocProvider(
      create: (context) => AuthBloc(
        signInWithGoogle: signInWithGoogle,
        sendMagicLink: sendMagicLink,
        checkAuthStatus: checkAuthStatus,
      )..add(CheckAuthStatusEvent()),
      child: const LoginScreenContent(),
    );
  }
}

class LoginScreenContent extends StatefulWidget {
  const LoginScreenContent({super.key});

  @override
  State<LoginScreenContent> createState() => _LoginScreenContentState();
}

class _LoginScreenContentState extends State<LoginScreenContent>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Bottom sheet slide animation - finishes at 600ms smooth
    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(
            0,
            1.5,
          ), // Start further below screen to avoid peek
          end: Offset.zero, // End at normal position
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(
              0.0,
              0.75,
              curve: Curves.easeOutCubic,
            ), // 0-600ms smooth
          ),
        );

    // Expanded shrink animation - finishes at 800ms (200ms after bottom sheet) with bouncy
    _expandAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false, // Ensure background stays put
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              // Trigger animation when user is confirmed unauthenticated
              if (_animationController.status == AnimationStatus.dismissed) {
                _animationController.forward();
              }
            }

            if (state is AuthAuthenticated) {
              // Navigation will happen, keep loading state visible
              // The router redirect will handle the actual navigation
              context.go(
                AppRoutes.onboarding,
                extra: {
                  'firstName': state.firstName,
                  'lastName': state.lastName,
                },
              );
            }

            if (state is MagicLinkSent) {
              MagicLinkDialog.show(context, state.email);
            }

            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: UiText(text: state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            // Button loading listens to isLoggingIn property
            final isLoading = state.isLoggingIn || (state is AuthAuthenticated);
            // Show initial loading (centered spinner) only for app startup check
            final isInitialLoading = state is AuthInitial;

            return Stack(
              children: [
                // Background image with animation
                LoginBackground(animation: _animationController),

                // Content
                SafeArea(
                  child: Column(
                    children: [
                      // Centered logo - expands/shrinks with animation
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          final flex = isInitialLoading
                              ? 1.0
                              : _expandAnimation.value;
                          return Expanded(
                            flex: (flex * 100).toInt(),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/kasi_hustle_logo.png',
                                    width: 140,
                                    fit: BoxFit.contain,
                                  ),
                                  if (isInitialLoading) ...[
                                    VSpace.lg,
                                    CircularProgressIndicator(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Bottom sheet with slide animation
                      if (!isInitialLoading) ...[
                        VSpace(Insets.xxxl * 4),

                        SlideTransition(
                          position: _slideAnimation,
                          child: LoginBottomSheet(
                            showEmailField: state.showEmailForm,
                            child: state.showEmailForm
                                ? EmailForm(
                                    emailController: _emailController,
                                    formKey: _formKey,
                                    isLoading: isLoading,
                                    onCancel: () {
                                      context.read<AuthBloc>().add(
                                        ToggleEmailFormEvent(false),
                                      );
                                      _emailController.clear();
                                    },
                                  )
                                : LoginOptions(
                                    isLoading: isLoading,
                                    onEmailPressed: () => context
                                        .read<AuthBloc>()
                                        .add(ToggleEmailFormEvent(true)),
                                  ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
