import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      // In real app: Use supabase.auth.signInWithOAuth(Provider.google)
      await Future.delayed(const Duration(seconds: 2));

      // Mock successful login
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
      // In real app: Use supabase.auth.signInWithOtp(email: event.email)
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
      // Check if user is already logged in
      // In real app: Check supabase.auth.currentSession
      await Future.delayed(const Duration(milliseconds: 500));

      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }
}

// ==================== LOGIN SCREEN ====================

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc()..add(CheckAuthStatus()),
      child: const LoginScreenContent(),
    );
  }
}

class LoginScreenContent extends StatefulWidget {
  const LoginScreenContent({Key? key}) : super(key: key);

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Navigate to home screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Welcome to Kasi Hustle! 🎉'),
                backgroundColor: Color(0xFFFFD700),
              ),
            );
            // TODO: Navigate to MainLayout()
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainLayout()));
          }

          if (state is MagicLinkSent) {
            setState(() {
              _showEmailField = false;
            });
            _showMagicLinkSentDialog(context, state.email);
          }

          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _showEmailField = false;
            });
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Stack(
            children: [
              // Background - Leave space for your image
              // You can add your background image here
              Container(
                color: Colors.black,
                // TODO: Add your background image
                // decoration: BoxDecoration(
                //   image: DecorationImage(
                //     image: AssetImage('assets/images/login_bg.png'),
                //     fit: BoxFit.cover,
                //   ),
                // ),
              ),

              // Gradient overlay to ensure text is readable
              Container(
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
              ),

              // Content
              SafeArea(
                child: Column(
                  children: [
                    const Spacer(),

                    // Bottom Rounded Container
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFFD700),
                            blurRadius: 20,
                            offset: Offset(0, -2),
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Drag indicator
                            Center(
                              child: Container(
                                width: 50,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Title
                            const Text(
                              'Get Started',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Subtitle
                            Text(
                              'Join the hustle. Find jobs or post work.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Email Field (conditionally shown)
                            if (_showEmailField) ...[
                              Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Enter your email',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _emailController,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        hintText: 'your.email@example.com',
                                        hintStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.4),
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.email_outlined,
                                          color: Color(0xFFFFD700),
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFF1A1A1A),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFFFD700),
                                            width: 2,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
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
                                    const SizedBox(height: 16),

                                    // Send Link Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : () {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  context.read<AuthBloc>().add(
                                                    SendMagicLink(
                                                      _emailController.text
                                                          .trim(),
                                                    ),
                                                  );
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFFFD700,
                                          ),
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.black,
                                                    ),
                                              )
                                            : const Text(
                                                'Send Magic Link',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Back button
                                    Center(
                                      child: TextButton(
                                        onPressed: isLoading
                                            ? null
                                            : () {
                                                setState(() {
                                                  _showEmailField = false;
                                                  _emailController.clear();
                                                });
                                              },
                                        child: const Text(
                                          'Back to options',
                                          style: TextStyle(
                                            color: Color(0xFFFFD700),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Login Options (shown when email field is hidden)
                            if (!_showEmailField) ...[
                              // Google Sign In Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          context.read<AuthBloc>().add(
                                            SignInWithGoogle(),
                                          );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  icon: isLoading
                                      ? const SizedBox.shrink()
                                      : Image.asset(
                                          'assets/images/google_icon.png',
                                          width: 24,
                                          height: 24,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                // Fallback to icon if image not found
                                                return const Icon(
                                                  Icons.g_mobiledata,
                                                  size: 28,
                                                  color: Colors.black,
                                                );
                                              },
                                        ),
                                  label: isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.black,
                                          ),
                                        )
                                      : const Text(
                                          'Continue with Google',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Divider with "OR"
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.white.withOpacity(0.2),
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'OR',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.white.withOpacity(0.2),
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Email Sign In Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: OutlinedButton.icon(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          setState(() {
                                            _showEmailField = true;
                                          });
                                        },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFFFD700),
                                    side: const BorderSide(
                                      color: Color(0xFFFFD700),
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.email_outlined,
                                    size: 24,
                                  ),
                                  label: const Text(
                                    'Continue with Email',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),

                            // Terms and Privacy
                            Center(
                              child: Text(
                                'By continuing, you agree to our Terms & Privacy Policy',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showMagicLinkSentDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                color: Color(0xFFFFD700),
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Check Your Email!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We sent a magic link to',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Click the link in your email to sign in.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Got it!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
