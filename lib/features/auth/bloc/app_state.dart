part of 'app_bloc.dart';

enum AppStatus { unknown, loading, authenticated, unauthenticated }

class AppState extends Equatable {
  final AppStatus status;
  final UserProfile? user;
  final bool profileCompleted;

  const AppState._({
    this.status = AppStatus.unknown,
    this.user,
    this.profileCompleted = false,
  });

  const AppState.unknown() : this._();

  const AppState.loading() : this._(status: AppStatus.loading);

  const AppState.authenticated({
    required UserProfile user,
    required bool profileCompleted,
  }) : this._(
         status: AppStatus.authenticated,
         user: user,
         profileCompleted: profileCompleted,
       );

  const AppState.unauthenticated() : this._(status: AppStatus.unauthenticated);

  @override
  List<Object?> get props => [status, user, profileCompleted];
}
