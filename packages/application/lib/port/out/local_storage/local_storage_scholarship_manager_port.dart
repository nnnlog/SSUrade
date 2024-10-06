import 'package:ssurade_application/domain/model/scholarship/scholarship_manager.dart';

abstract interface class LocalStorageScholarshipManagerPort {
  Future<ScholarshipManager?> retrieveScholarshipManager();

  Future<void> saveScholarshipManager(ScholarshipManager scholarshipManager);
}
