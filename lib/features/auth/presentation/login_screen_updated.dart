import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/buttons/primary_btn.dart';
import 'package:kasi_hustle/core/widgets/buttons/secondary_btn.dart';
import 'package:kasi_hustle/core/widgets/styled_text_input.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/features/onboarding/presentation/screens/onboarding_screen.dart';

// ==================== BLOC EVENTS ====================

abstract class AuthEvent {}

class SignInWithGoogle extends AuthEvent {}

class SendMagicLink extends AuthEvent {
  final String email;
  SendMagicLink(this.email);
}

class CheckAuthStatus extends AuthEvent {}

// ==================== BLOC STATES ====================

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class MagicLinkSent extends AuthState {
  final String email;
  MagicLinkSent(this.email);
}

class AuthAuthenticated extends AuthState {
  final String userId;
  final String email;
  AuthAuthenticated({required this.userId, required this.email});
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// ==================== BLOC ====================

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<SignInWithGoogle>(_onSignInWithGoogle);
    on<SendMagicLink>(_onSendMagicLink);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Simulate Google Sign-In
      await Future.delayed(const Duration(seconds: 2));
      emit(AuthAuthenticated(userId: 'user123', email: 'user@example.com'));
    } catch (e) {
      emit(AuthError('Google sign-in failed. Please try again.'));
    }
  }

  Future<void> _onSendMagicLink(
    SendMagicLink event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Simulate sending magic link
      await Future.delayed(const Duration(seconds: 2));
      emit(MagicLinkSent(event.email));
    } catch (e) {
      emit(AuthError('Failed to send magic link. Please try again.'));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }
}

// ==================== LOGIN SCREEN ====================

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc()..add(CheckAuthStatus()),
      child: const LoginScreenContent(),
    );
  }
}

class LoginScreenContent extends StatefulWidget {
  const LoginScreenContent({super.key});

  @override
  State<LoginScreenContent> createState() => _LoginScreenContentState();
}

class _LoginScreenContentState extends State<LoginScreenContent> {
  bool _showEmailField = false;
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure system bars match the app theme for this screen.
    final ThemeData theme = Theme.of(context);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: theme.colorScheme.surface,
        systemNavigationBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            );
          }

          if (state is MagicLinkSent) {
            setState(() => _showEmailField = false);
            _showMagicLinkSentDialog(context, state.email);
          }

          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: UiText(text: state.message),
                backgroundColor: Colors.red,
              ),
            );
            setState(() => _showEmailField = false);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Stack(
            children: [
              // Background image and gradient
              _buildBackground(),
              // _buildGradientOverlay(),

              // Content
              SafeArea(
                child: Column(
                  children: [
                    // Top image area (70% of screen) with centered logo
                    Expanded(
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            // color: Theme.of(context).scaffoldBackgroundColor,
                            // borderRadius: BorderRadius.circular(Corners.xxl),
                            // boxShadow: Shadows.medium,
                          ),
                          child: Image.asset(
                            'assets/images/kasi_hustle_logo.png',
                            width: 140,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    VSpace(Insets.xxxl * 4),
                    // Bottom sheet takes remaining space
                    _buildBottomSheet(context, isLoading),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.70,
            width: double.infinity,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/login_bg.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),
          Expanded(child: Container(color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.8),
            Colors.black,
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context, bool isLoading) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF4EDE3),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Corners.xxl),
          topRight: Radius.circular(Corners.xxl),
        ),
        boxShadow: Shadows.medium,
      ),
      child: Padding(
        padding: EdgeInsets.all(Insets.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildDragIndicator(),
            VSpace.xl,
            _buildTitle(),
            VSpace.xs,
            _buildSubtitle(),
            VSpace.xxl,
            if (_showEmailField) _buildEmailForm(isLoading),
            if (!_showEmailField) _buildLoginOptions(isLoading),
            VSpace.xl,
            _buildTermsText(),
          ],
        ),
      ),
    );
  }

  Widget _buildDragIndicator() {
    return Center(
      child: Container(
        width: Sizes.hit,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Corners.xs),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return UiText(
      text: _showEmailField ? 'Enter your email' : 'Get Started',
      style: TextStyles.headlineSmall.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildSubtitle() {
    return UiText(
      text: _showEmailField
          ? 'We will send a magic link to this email.'
          : 'Join the hustle. Find jobs or post work.',
      style: TextStyles.bodyLarge.copyWith(
        color: Colors.black.withOpacity(0.7),
      ),
    );
  }

  Widget _buildEmailForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StyledTextInput(
            controller: _emailController,
            hintText: 'your.email@example.com',
            prefixIcon: Icon(
              Icons.email_outlined,
              size: IconSizes.med,
              color: const Color(0xFF2E1C13),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          VSpace.lg,
          Row(
            children: [
              Expanded(
                child: PrimaryBtn(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                              SendMagicLink(_emailController.text.trim()),
                            );
                          }
                        },
                  label: 'Send Magic Link',
                  isLoading: isLoading,
                ),
              ),
            ],
          ),
          VSpace.med,
          Center(
            child: CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF2E1C13).withOpacity(0.1),
              child: IconButton(
                onPressed: isLoading
                    ? null
                    : () {
                        setState(() {
                          _showEmailField = false;
                          _emailController.clear();
                        });
                      },
                splashRadius: 20,
                icon: Icon(
                  Ionicons.close,
                  size: IconSizes.sm,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginOptions(bool isLoading) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PrimaryBtn(
                onPressed: isLoading
                    ? null
                    : () => context.read<AuthBloc>().add(SignInWithGoogle()),
                label: 'Continue with Google',
                icon: Ionicons.logo_google,
                isLoading: isLoading,
              ),
            ),
          ],
        ),
        VSpace.lg,
        Row(
          children: [
            Expanded(
              child: SecondaryBtn(
                onPressed: isLoading
                    ? null
                    : () => setState(() => _showEmailField = true),
                label: 'Continue with Email',
                icon: Icons.email_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTermsText() {
    return UiText(
      text: 'By continuing, you agree to our Terms & Privacy Policy',
      style: TextStyles.caption.copyWith(color: Colors.black.withOpacity(0.5)),
      textAlign: TextAlign.center,
    );
  }

  void _showMagicLinkSentDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.xl),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Sizes.hit * 2,
              height: Sizes.hit * 2,
              decoration: BoxDecoration(
                color: const Color(0xFFF4EDE3).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_read_outlined,
                color: const Color(0xFFF4EDE3),
                size: IconSizes.xl,
              ),
            ),
            VSpace.xl,
            UiText(
              text: 'Check Your Email!',
              style: TextStyles.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            VSpace.med,
            UiText(
              text: 'We sent a magic link to',
              style: TextStyles.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            VSpace.xs,
            UiText(
              text: email,
              style: TextStyles.bodyMedium.copyWith(
                color: const Color(0xFFF4EDE3),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            VSpace.med,
            UiText(
              text: 'Click the link in your email to sign in.',
              style: TextStyles.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            VSpace.xl,
            PrimaryBtn(
              onPressed: () => Navigator.pop(dialogContext),
              label: 'Got it!',
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  const Color(0xFFF4EDE3),
                ),
                foregroundColor: MaterialStatePropertyAll(Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
