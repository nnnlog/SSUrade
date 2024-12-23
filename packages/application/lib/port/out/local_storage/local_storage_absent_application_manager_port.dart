import 'package:ssurade_application/domain/model/absent_application/absent_application_manager.dart';

abstract interface class LocalStorageAbsentApplicationManagerPort {
  Future<AbsentApplicationManager?> retrieveAbsentApplicationManager();

  Future<void> saveAbsentApplicationManager(AbsentApplicationManager absentApplicationManager);
}
