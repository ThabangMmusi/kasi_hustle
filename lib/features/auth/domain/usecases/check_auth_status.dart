import 'package:kasi_hustle/features/auth/domain/repositories/auth_repository.dart';

typedef CheckAuthStatus = Future<bool> Function();

CheckAuthStatus makeCheckAuthStatus(AuthRepository repository) {
  return () => repository.checkAuthStatus();
}
