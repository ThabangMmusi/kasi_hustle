part of 'auth_bloc.dart';

abstract class AuthState {
  final bool showEmailForm;
  final bool isLoggingIn; // true when user actively logging in
  AuthState({this.showEmailForm = false, this.isLoggingIn = false});
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {
  AuthLoading({super.showEmailForm});
}

class MagicLinkSent extends AuthState {
  final String email;
  MagicLinkSent(this.email);
}

class AuthAuthenticated extends AuthState {
  final String userId;
  final String email;
  final String? firstName;
  final String? lastName;
  AuthAuthenticated({
    required this.userId,
    required this.email,
    this.firstName,
    this.lastName,
  });
}

class AuthUnauthenticated extends AuthState {
  AuthUnauthenticated({super.showEmailForm, super.isLoggingIn});
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message, {super.showEmailForm});
}
