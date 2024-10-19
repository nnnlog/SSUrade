import 'package:ssurade_application/domain/model/credential/credential.dart';

abstract interface class LoginViewModelUseCase {
  Future<Credential?> getCredential();

  Future<bool> loadNewCredential(Credential credential);

  Future<void> clearCredential();

  Stream<Credential> getCredentialStream();

  Future<bool> validateCredential(Credential credential);
}
