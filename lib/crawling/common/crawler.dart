import 'package:ssurade/crawling/common/webview_worker.dart';
import 'package:ssurade/crawling/tasks/combine/all_chapel.dart';
import 'package:ssurade/crawling/tasks/combine/all_grade.dart';
import 'package:ssurade/crawling/tasks/combine/all_grade_by_category.dart';
import 'package:ssurade/crawling/tasks/combine/all_grade_by_semester.dart';
import 'package:ssurade/crawling/tasks/combine/semester_subject_detail_grade.dart';
import 'package:ssurade/crawling/tasks/units/extract_data_from_viewer.dart';
import 'package:ssurade/crawling/tasks/units/get_scholarship.dart';
import 'package:ssurade/crawling/tasks/units/grade_semester_list.dart';
import 'package:ssurade/crawling/tasks/units/login_session.dart';
import 'package:ssurade/crawling/tasks/units/single_absent_by_semester.dart';
import 'package:ssurade/crawling/tasks/units/single_chapel_by_semester.dart';
import 'package:ssurade/crawling/tasks/units/single_grade_by_semester.dart';
import 'package:ssurade/crawling/tasks/units/single_grade_by_semester_old_version.dart';
import 'package:ssurade/crawling/tasks/units/subject_detail_grade.dart';
import 'package:ssurade/crawling/tasks/units/weburl_by_category.dart';

class Crawler {
  Crawler._(); // do not create class

  static final WebViewWorker worker = WebViewWorker();

  static const loginSession = LoginSession.get;
  static const webUrlByCategory = WebUrlByCategory.get;
  static const extractDataFromViewer = ExtractDataFromViewer.get;
  static const allGrade = AllGrade.get;
  static const allGradeByCategory = AllGradeByCategory.get;
  static const allGradeBySemester = AllGradeBySemester.get;
  static const gradeSemesterList = GradeSemesterList.get;
  static const singleGradeBySemester = SingleGradeBySemester.get;
  static const singleGradeBySemesterOldVersion = SingleGradeBySemesterOldVersion.get;
  static const subjectDetailGrade = SubjectDetailGrade.get;
  static const semesterSubjectDetailGrade = SemesterSubjectDetailGrade.get;
  static const singleChapelBySemester = SingleChapelBySemester.get;
  static const allChapel = AllChapel.get;
  static const getScholarship = GetScholarship.get;
  static const singleAbsentBySemester = SingleAbsentBySemester.get;
}
