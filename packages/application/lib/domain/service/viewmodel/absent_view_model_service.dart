import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:ssurade_application/domain/model/absent_application/absent_application_manager.dart';
import 'package:ssurade_application/port/in/viewmodel/absent_view_model_use_case.dart';
import 'package:ssurade_application/port/out/application/toast_port.dart';
import 'package:ssurade_application/port/out/external/external_absent_application_retrieval_port.dart';
import 'package:ssurade_application/port/out/local_storage/local_storage_absent_application_manager_port.dart';

@Singleton(as: AbsentViewModelUseCase)
class AbsentViewModelService implements AbsentViewModelUseCase {
  final StreamController<AbsentApplicationManager> _streamController = StreamController.broadcast();
  final LocalStorageAbsentApplicationManagerPort _localStorageAbsentApplicationManagerPort;
  final ExternalAbsentApplicationRetrievalPort _externalAbsentApplicationRetrievalPort;
  final ToastPort _toastPort;

  AbsentViewModelService({
    required LocalStorageAbsentApplicationManagerPort localStorageAbsentApplicationManagerPort,
    required ExternalAbsentApplicationRetrievalPort externalAbsentApplicationRetrievalPort,
    required ToastPort toastPort,
  })  : _localStorageAbsentApplicationManagerPort = localStorageAbsentApplicationManagerPort,
        _externalAbsentApplicationRetrievalPort = externalAbsentApplicationRetrievalPort,
        _toastPort = toastPort;

  @override
  Future<AbsentApplicationManager?> getAbsentManager() {
    return _localStorageAbsentApplicationManagerPort.retrieveAbsentApplicationManager();
  }

  @override
  Future<bool> loadNewAbsentManager() async {
    var scholarshipManager = await _externalAbsentApplicationRetrievalPort.retrieveAbsentManager().result;
    if (scholarshipManager == null) {
      await _toastPort.showToast('Failed to load absent manager');
      return false;
    }

    await _localStorageAbsentApplicationManagerPort.saveAbsentApplicationManager(scholarshipManager);
    _streamController.add(scholarshipManager);
    return true;
  }

  @override
  Future<void> clearAbsentManager() async {
    final absentManager = AbsentApplicationManager.empty();
    await _localStorageAbsentApplicationManagerPort.saveAbsentApplicationManager(absentManager);
    _streamController.add(absentManager);
  }

  @override
  Stream<AbsentApplicationManager> getAbsentManagerStream() {
    return _streamController.stream.asBroadcastStream();
  }

  @override
  Future<void> showToast(String message) async {
    await _toastPort.showToast(message);
  }
}
