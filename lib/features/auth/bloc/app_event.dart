part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

class AppUserChanged extends AppEvent {
  final User? user;

  const AppUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AppLogoutRequested extends AppEvent {
  const AppLogoutRequested();
}

class AppProfileCreated extends AppEvent {
  final UserProfile profile;

  const AppProfileCreated(this.profile);

  @override
  List<Object?> get props => [profile];
}
