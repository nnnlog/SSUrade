import 'package:injectable/injectable.dart';
import 'package:ssurade_adaptor/crawling/cache/credential_manager_service.dart';
import 'package:ssurade_adaptor/persistence/client/secure_storage_client.dart';
import 'package:ssurade_application/ssurade_application.dart';

@Singleton(as: LocalStorageCredentialPort)
class LocalStorageCredentialService implements LocalStorageCredentialPort {
  final SecureStorageClient _secureStorage;
  final CredentialManagerService _credentialManagerService;

  const LocalStorageCredentialService(this._secureStorage, this._credentialManagerService);

  static String get _idKey => "id";

  static String get _pwKey => "pw";

  @override
  Future<Credential?> retrieveCredential() async {
    final id = await _secureStorage.read(_idKey), pw = await _secureStorage.read(_pwKey);
    if (id == null || pw == null) return null;
    return Credential(
      id: id,
      password: pw,
    );
  }

  @override
  Future<void> saveCredential(Credential credential) async {
    await _credentialManagerService.clearCookies();

    await Future.wait([
      _secureStorage.write(_idKey, credential.id),
      _secureStorage.write(_pwKey, credential.password),
    ]);
  }
}
