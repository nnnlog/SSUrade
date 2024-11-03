import 'package:ssurade_application/domain/model/scholarship/scholarship_manager.dart';

abstract interface class ScholarshipViewModelUseCase {
  Future<ScholarshipManager?> getScholarshipManager();

  Future<bool> loadNewScholarshipManager();

  Future<void> clearScholarshipManager();

  Stream<ScholarshipManager> getScholarshipManagerStream();

  Future<void> showToast(String message);
}
