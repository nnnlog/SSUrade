import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_adaptor/persistence/client/secure_storage_client.dart';
import 'package:ssurade_application/ssurade_application.dart';

@module
abstract class LocalStorageCredentialServiceModule {
  @injectable
  LocalStorageCredentialPort get localStorageCredentialPort => GetIt.I.get<LocalStorageCredentialService>();
}

@singleton
class LocalStorageCredentialService implements LocalStorageCredentialPort {
  final SecureStorageClient _secureStorage;
  final StreamController<Credential> _controller = StreamController.broadcast();

  LocalStorageCredentialService(this._secureStorage);

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
    _controller.add(credential);
    await Future.wait([
      _secureStorage.write(_idKey, credential.id),
      _secureStorage.write(_pwKey, credential.password),
    ]);
  }

  Stream get onCredentialChanged => _controller.stream.asBroadcastStream();
}
