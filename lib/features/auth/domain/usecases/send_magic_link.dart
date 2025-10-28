import 'package:kasi_hustle/features/auth/domain/repositories/auth_repository.dart';

typedef SendMagicLink = Future<void> Function(String email);

SendMagicLink makeSendMagicLink(AuthRepository repository) {
  return (email) => repository.sendMagicLink(email);
}
