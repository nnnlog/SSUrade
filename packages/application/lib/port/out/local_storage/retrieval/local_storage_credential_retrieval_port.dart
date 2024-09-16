import 'package:ssurade_application/domain/model/credential/credential.dart';

abstract interface class LocalStorageCredentialRetrievalPort {
  Future<Credential?> retrieveCredential();
}
