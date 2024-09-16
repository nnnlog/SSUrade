import 'package:ssurade_application/domain/model/setting/background_setting.dart';

abstract interface class LocalStorageBackgroundSettingSavePort {
  Future<void> saveBackgroundSetting(BackgroundSetting backgroundSetting);
}
