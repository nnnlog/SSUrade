import 'package:ssurade_application/domain/model/scholarship/scholarship_manager.dart';

abstract interface class ScholarshipDataPort {
  ScholarshipManager getScholarshipManager();

  void setScholarshipManager(ScholarshipManager scholarshipManager);
}
