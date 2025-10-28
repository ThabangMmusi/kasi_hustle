import 'package:kasi_hustle/features/auth/domain/repositories/auth_repository.dart';

typedef SignInWithGoogle = Future<Map<String, dynamic>> Function();

SignInWithGoogle makeSignInWithGoogle(AuthRepository repository) {
  return () => repository.signInWithGoogle();
}
