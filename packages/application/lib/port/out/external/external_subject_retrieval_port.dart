import 'package:ssurade_application/domain/model/job/job.dart';
import 'package:ssurade_application/domain/model/semester/year_semester.dart';
import 'package:ssurade_application/domain/model/subject/semester_subjects.dart';
import 'package:ssurade_application/domain/model/subject/semester_subjects_manager.dart';

abstract interface class ExternalSubjectRetrievalPort {
  Job<SemesterSubjects> retrieveSemesterSubjects(
    YearSemester yearSemester, {
    bool includeDetail = false,
  });

  Job<SemesterSubjectsManager> retrieveAllSemesterSubjects({
    bool includeDetail = false,
  });
}
