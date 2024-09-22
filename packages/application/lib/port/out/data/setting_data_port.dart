import 'package:ssurade_application/domain/model/setting/setting.dart';

abstract interface class SettingDataPort {
  Setting getSetting();

  void setSetting(Setting setting);
}
