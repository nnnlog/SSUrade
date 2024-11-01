import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:ssurade_application/domain/model/credential/credential.dart';
import 'package:ssurade_application/domain/model/error/unauthenticated_exception.dart';
import 'package:ssurade_application/port/in/viewmodel/login_view_model_use_case.dart';
import 'package:ssurade_application/port/out/application/toast_port.dart';
import 'package:ssurade_application/port/out/external/external_credential_retrieval_port.dart';
import 'package:ssurade_application/port/out/local_storage/local_storage_credential_port.dart';

@Singleton(as: LoginViewModelUseCase)
class LoginViewModelService implements LoginViewModelUseCase {
  final StreamController<Credential> _streamController = StreamController.broadcast();
  final LocalStorageCredentialPort _localStorageCredentialPort;
  final ExternalCredentialRetrievalPort _externalCredentialRetrievalPort;
  final ToastPort _toastPort;

  LoginViewModelService({
    required LocalStorageCredentialPort localStorageCredentialPort,
    required ExternalCredentialRetrievalPort externalCredentialRetrievalPort,
    required ToastPort toastPort,
  })  : _localStorageCredentialPort = localStorageCredentialPort,
        _externalCredentialRetrievalPort = externalCredentialRetrievalPort,
        _toastPort = toastPort;

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
    return validateCredential(credential);
  }

  @override
  Future<bool> validateCredential(Credential credential) async {
    return await _externalCredentialRetrievalPort.getCookiesFromCredential(credential).result.catchError(
              (error) => null,
              test: (error) => error is UnauthenticatedException,
            ) !=
        null;
  }

  @override
  Future<void> showToast(String message) async {
    await _toastPort.showToast(message);
  }
}
