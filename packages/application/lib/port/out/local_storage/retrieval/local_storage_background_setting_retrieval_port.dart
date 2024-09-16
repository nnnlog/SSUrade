import 'package:ssurade_application/domain/model/setting/background_setting.dart';

abstract interface class LocalStorageBackgroundSettingRetrievalPort {
  Future<BackgroundSetting?> retrieveBackgroundSetting();
}
