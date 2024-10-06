import 'package:ssurade_application/domain/model/credential/credential.dart';

abstract interface class LoginViewModelUseCase {
  Future<Credential?> getCredential();

  Future<bool> loadNewCredential(Credential credential);

  Future<void> clearCredential();

  Future<bool> validateCurrentCredential();

  Stream<Credential> getCredentialStream();
}
