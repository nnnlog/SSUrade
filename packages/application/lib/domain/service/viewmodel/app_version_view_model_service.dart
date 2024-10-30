import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:ssurade_application/domain/model/absent_application/absent_application_manager.dart';
import 'package:ssurade_application/domain/model/application/app_version.dart';
import 'package:ssurade_application/port/in/viewmodel/absent_view_model_use_case.dart';
import 'package:ssurade_application/port/in/viewmodel/app_version_view_model_use_case.dart';
import 'package:ssurade_application/port/out/application/app_version_fetch_port.dart';
import 'package:ssurade_application/port/out/application/toast_port.dart';
import 'package:ssurade_application/port/out/external/external_absent_application_retrieval_port.dart';
import 'package:ssurade_application/port/out/local_storage/local_storage_absent_application_manager_port.dart';

@Singleton(as: AppVersionViewModelUseCase)
class AppVersionViewModelService implements AppVersionViewModelUseCase {
  final AppVersionFetchPort _appVersionFetchPort;

  AppVersionViewModelService({
    required AppVersionFetchPort appVersionFetchPort,
  }) : this._appVersionFetchPort = appVersionFetchPort;

  @override
  Future<AppVersion?> getAppVersion() {
    return _appVersionFetchPort.fetchAppVersion();
  }
}
