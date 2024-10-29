import 'package:ssurade_application/domain/model/absent_application/absent_application_manager.dart';

abstract interface class AbsentViewModelUseCase {
  Future<AbsentApplicationManager?> getAbsentManager();

  Future<bool> loadNewAbsentManager();

  Future<void> clearAbsentManager();

  Stream<AbsentApplicationManager> getAbsentManagerStream();

  Future<void> showToast(String message);
}
