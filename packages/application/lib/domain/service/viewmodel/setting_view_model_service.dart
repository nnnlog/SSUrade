import 'dart:async';

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_application/domain/model/credential/credential.dart';
import 'package:ssurade_application/domain/model/setting/setting.dart';
import 'package:ssurade_application/port/in/viewmodel/login_view_model_use_case.dart';
import 'package:ssurade_application/port/in/viewmodel/setting_view_model_use_case.dart';
import 'package:ssurade_application/port/out/application/background_process_management_port.dart';
import 'package:ssurade_application/port/out/application/toast_port.dart';
import 'package:ssurade_application/port/out/external/external_credential_retrieval_port.dart';
import 'package:ssurade_application/port/out/local_storage/local_storage_credential_port.dart';
import 'package:ssurade_application/port/out/local_storage/local_storage_setting_port.dart';

@Singleton(as: SettingViewModelUseCase)
class SettingViewModelService implements SettingViewModelUseCase {
  final StreamController<Setting> _streamController = StreamController.broadcast();
  final LocalStorageSettingPort _localStorageSettingPort;
  final BackgroundProcessManagementPort _backgroundProcessManagementPort;
  final ToastPort _toastPort;

  SettingViewModelService({
    required LocalStorageSettingPort localStorageSettingPort,
    required BackgroundProcessManagementPort backgroundProcessManagementPort,
    required ToastPort toastPort,
  })  : _localStorageSettingPort = localStorageSettingPort,
        _backgroundProcessManagementPort = backgroundProcessManagementPort,
        _toastPort = toastPort;

  @override
  Future<Setting?> getSetting() {
    return _localStorageSettingPort.retrieveSetting();
  }

  @override
  Stream<Setting> getSettingStream() {
    return _streamController.stream.asBroadcastStream();
  }

  @override
  Future<void> applyNewSetting(Setting setting) async {
    // TODO: for each feature, separate the logic to its own use case (like event handler)
    {
      // background feature block
      if (setting.enableBackgroundFeature) {
        await _backgroundProcessManagementPort.registerBackgroundService(setting.backgroundInterval);
      } else {
        await _backgroundProcessManagementPort.unregisterBackgroundService();
      }
    }

    await _localStorageSettingPort.saveSetting(setting);

    _streamController.add(setting);
  }

  Future<void> showToast(String message) {
    return _toastPort.showToast(message);
  }
}
