import 'package:ssurade_application/domain/model/subject/semester_subjects_manager.dart';

abstract interface class LocalStorageSemesterSubjectsManagerSavePort {
  Future<void> saveSemesterSubjectsManager(SemesterSubjectsManager semesterSubjectsManager);
}
