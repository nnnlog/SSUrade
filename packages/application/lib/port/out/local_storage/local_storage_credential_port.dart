import 'package:ssurade_application/domain/model/credential/credential.dart';

abstract interface class LocalStorageCredentialPort {
  Future<Credential?> retrieveCredential();

  Future<void> saveCredential(Credential credential);
}
