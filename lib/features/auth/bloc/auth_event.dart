part of 'auth_bloc.dart';

abstract class AuthEvent {}

class SignInWithGoogleEvent extends AuthEvent {}

class SendMagicLinkEvent extends AuthEvent {
  final String email;
  SendMagicLinkEvent(this.email);
}

class CheckAuthStatusEvent extends AuthEvent {}

class ToggleEmailFormEvent extends AuthEvent {
  final bool show;
  ToggleEmailFormEvent(this.show);
}
