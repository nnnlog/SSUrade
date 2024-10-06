import 'package:ssurade_application/domain/model/setting/setting.dart';

abstract interface class LocalStorageSettingPort {
  Future<Setting?> retrieveSetting();

  Future<void> saveSetting(Setting setting);
}
