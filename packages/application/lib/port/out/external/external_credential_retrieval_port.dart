import 'package:ssurade_application/domain/model/credential/credential.dart';
import 'package:ssurade_application/domain/model/job/job.dart';

abstract interface class ExternalCredentialRetrievalPort {
  Job<List<Map<String, dynamic>>?> getCookiesFromCredential(Credential credential);
}
