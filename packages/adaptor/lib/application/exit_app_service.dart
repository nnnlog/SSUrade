import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_application/ssurade_application.dart';

@Singleton(as: ExitAppPort)
class ExitAppService implements ExitAppPort {
  @override
  void exitApp() {
    FlutterExitApp.exitApp();
  }
}
