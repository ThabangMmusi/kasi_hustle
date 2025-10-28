import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasi_hustle/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:kasi_hustle/features/auth/domain/usecases/send_magic_link.dart';
import 'package:kasi_hustle/features/auth/domain/usecases/check_auth_status.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle signInWithGoogle;
  final SendMagicLink sendMagicLink;
  final CheckAuthStatus checkAuthStatus;

  AuthBloc({
    required this.signInWithGoogle,
    required this.sendMagicLink,
    required this.checkAuthStatus,
  }) : super(AuthInitial()) {
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SendMagicLinkEvent>(_onSendMagicLink);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<ToggleEmailFormEvent>(_onToggleEmailForm);
  }

  Future<void> _onToggleEmailForm(
    ToggleEmailFormEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthUnauthenticated) {
      emit(AuthUnauthenticated(showEmailForm: event.show));
    }
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    final currentShowEmail = state.showEmailForm;
    emit(
      AuthUnauthenticated(
        showEmailForm: currentShowEmail,
        isLoggingIn: true, // User clicked login button
      ),
    );
    try {
      final result = await signInWithGoogle();
      emit(
        AuthAuthenticated(
          userId: result['userId'] as String,
          email: result['email'] as String,
          firstName: result['firstName'] as String?,
          lastName: result['lastName'] as String?,
        ),
      );
    } catch (e) {
      emit(
        AuthError(
          'Google sign-in failed. Please try again.',
          showEmailForm: currentShowEmail,
        ),
      );
    }
  }

  Future<void> _onSendMagicLink(
    SendMagicLinkEvent event,
    Emitter<AuthState> emit,
  ) async {
    final currentShowEmail = state.showEmailForm;
    emit(
      AuthUnauthenticated(
        showEmailForm: currentShowEmail,
        isLoggingIn: true, // User clicked login button
      ),
    );
    try {
      await sendMagicLink(event.email);
      emit(MagicLinkSent(event.email));
    } catch (e) {
      emit(
        AuthError(
          'Failed to send magic link. Please try again.',
          showEmailForm: currentShowEmail,
        ),
      );
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthInitial());
    try {
      final isAuthenticated = await checkAuthStatus();
      if (isAuthenticated) {
        emit(AuthAuthenticated(userId: 'user123', email: 'user@example.com'));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }
}
