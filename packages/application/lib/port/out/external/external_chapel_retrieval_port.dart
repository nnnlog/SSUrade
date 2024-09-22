import 'package:ssurade_application/domain/model/chapel/chapel.dart';
import 'package:ssurade_application/domain/model/job/job.dart';
import 'package:ssurade_application/domain/model/semester/year_semester.dart';

abstract interface class ExternalChapelManagerRetrievalPort {
  Job<List<Chapel>> retrieveChapels(List<YearSemester> yearSemesters);

  Job<Chapel?> retrieveChapel(YearSemester yearSemester);
}
