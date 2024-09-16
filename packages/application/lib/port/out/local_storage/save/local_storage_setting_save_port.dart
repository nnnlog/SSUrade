import 'package:ssurade_application/domain/model/setting/setting.dart';

abstract interface class LocalStorageSettingSavePort {
  Future<void> saveSetting(Setting setting);
}
