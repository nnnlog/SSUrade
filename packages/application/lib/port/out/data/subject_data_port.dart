import 'package:ssurade_application/domain/model/subject/semester_subjects_manager.dart';

abstract interface class SubjectDataPort {
  SemesterSubjectsManager getSemesterSubjectsManager();

  void setSemesterSubjectsManager(SemesterSubjectsManager semesterSubjectsManager);
}
