import 'package:ssurade_application/domain/model/setting/setting.dart';

abstract interface class SettingViewModelUseCase {
  Future<Setting?> getSetting();

  Future<void> applyNewSetting(Setting credential);

  Stream<Setting> getSettingStream();

  Future<void> showToast(String message);
}
