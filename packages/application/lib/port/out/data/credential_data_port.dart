import 'package:ssurade_application/domain/model/credential/credential.dart';

abstract interface class CredentialDataPort {
  Credential getCredential();

  void setCredential(Credential credential);
}
