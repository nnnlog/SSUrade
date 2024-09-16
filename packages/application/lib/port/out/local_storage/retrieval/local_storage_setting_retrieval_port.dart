import 'package:ssurade_application/domain/model/setting/setting.dart';

abstract interface class LocalStorageSettingRetrievalPort {
  Future<Setting?> retrieveSetting();
}
