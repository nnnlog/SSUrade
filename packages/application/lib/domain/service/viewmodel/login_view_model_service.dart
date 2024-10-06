import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:ssurade_application/domain/model/credential/credential.dart';
import 'package:ssurade_application/port/in/viewmodel/login_view_model_use_case.dart';
import 'package:ssurade_application/port/out/external/external_credential_retrieval_port.dart';
import 'package:ssurade_application/port/out/local_storage/local_storage_credential_port.dart';

@Singleton(as: LoginViewModelUseCase)
class LoginViewModelService implements LoginViewModelUseCase {
  final StreamController<Credential> _streamController = StreamController.broadcast();
  final LocalStorageCredentialPort _localStorageCredentialPort;
  final ExternalCredentialRetrievalPort _externalCredentialRetrievalPort;

  LoginViewModelService({
    required LocalStorageCredentialPort localStorageCredentialPort,
    required ExternalCredentialRetrievalPort externalCredentialRetrievalPort,
  })  : _localStorageCredentialPort = localStorageCredentialPort,
        _externalCredentialRetrievalPort = externalCredentialRetrievalPort;

  @override
  Future<void> clearCredential() async {
    final credential = Credential.empty();
    await _localStorageCredentialPort.saveCredential(credential);
    _streamController.add(credential);
  }

  @override
  Future<Credential?> getCredential() {
    return _localStorageCredentialPort.retrieveCredential();
  }

  @override
  Stream<Credential> getCredentialStream() {
    return _streamController.stream.asBroadcastStream();
  }

  @override
  Future<bool> loadNewCredential(Credential credential) async {
    await _localStorageCredentialPort.saveCredential(credential);
    _streamController.add(credential);
    return validateCurrentCredential();
  }

  @override
  Future<bool> validateCurrentCredential() async {
    final credential = await _localStorageCredentialPort.retrieveCredential();
    if (credential == null) {
      return false;
    }
    final cookies = await _externalCredentialRetrievalPort.getCookiesFromCredential(credential).result;
    if (cookies != null) {
      _localStorageCredentialPort.saveCredential(credential.copyWith(cookies: cookies));
      return true;
    }
    return false;
  }
}
