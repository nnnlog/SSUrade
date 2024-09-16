import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_adaptor/persistence/client/secure_storage_client.dart';
import 'package:ssurade_application/ssurade_application.dart';

@module
abstract class LocalStorageCredentialServiceModule {
  @injectable
  LocalStorageCredentialRetrievalPort get i1 => GetIt.I.get<LocalStorageCredentialService>();

  @injectable
  LocalStorageCredentialSavePort get i2 => GetIt.I.get<LocalStorageCredentialService>();
}

@singleton
class LocalStorageCredentialService implements LocalStorageCredentialRetrievalPort, LocalStorageCredentialSavePort {
  final SecureStorageClient _secureStorage;

  const LocalStorageCredentialService(this._secureStorage);

  static String get _idKey => "id";

  static String get _pwKey => "pw";

  static String get _cookieKey => "cookie";

  @override
  Future<Credential?> retrieveCredential() async {
    final id = await _secureStorage.read(_idKey), pw = await _secureStorage.read(_pwKey), cookie = await _secureStorage.read(_cookieKey);
    if (id == null || pw == null || cookie == null) return null;
    return Credential(
      id: id,
      password: pw,
      cookies: jsonDecode(cookie),
    );
  }

  @override
  Future<void> saveCredential(Credential credential) async {
    await Future.wait([
      _secureStorage.write(_idKey, credential.id),
      _secureStorage.write(_pwKey, credential.password),
      _secureStorage.write(_cookieKey, jsonEncode(credential.cookies)),
    ]);
  }
}
