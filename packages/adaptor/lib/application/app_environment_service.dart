import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_application/port/out/application/app_environment_port.dart';

@Singleton(as: AppEnvironmentPort)
class AppEnvironmentService implements AppEnvironmentPort {
  @override
  AppEnvironment getEnvironment() {
    return kDebugMode ? AppEnvironment.debug : AppEnvironment.production;
  }
}
