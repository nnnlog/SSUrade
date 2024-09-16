import 'package:ssurade_application/domain/model/credential/credential.dart';

abstract interface class LocalStorageCredentialSavePort {
  Future<void> saveCredential(Credential credential);
}
