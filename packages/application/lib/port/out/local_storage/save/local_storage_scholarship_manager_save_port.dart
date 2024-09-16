import 'package:ssurade_application/domain/model/scholarship/scholarship_manager.dart';

abstract interface class LocalStorageScholarshipManagerSavePort {
  Future<void> saveScholarshipManager(ScholarshipManager scholarshipManager);
}
