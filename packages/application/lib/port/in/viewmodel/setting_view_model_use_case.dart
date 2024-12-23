import 'package:ssurade_application/domain/model/setting/setting.dart';

abstract interface class SettingViewModelUseCase {
  Future<Setting?> getSetting();

  Future<void> applyBackgroundFeature(Setting setting);

  Future<void> applyNewSetting(Setting setting);

  Stream<Setting> getSettingStream();

  Future<void> showToast(String message);
}
