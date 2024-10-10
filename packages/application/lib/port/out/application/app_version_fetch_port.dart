import 'package:ssurade_application/domain/model/application/app_version.dart';

abstract interface class AppVersionFetchPort {
  Future<AppVersion?> fetchAppVersion();
}
