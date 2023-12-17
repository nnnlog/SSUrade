import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/WebViewWorker.dart';
import 'package:ssurade/crawling/tasks/AllGrade.dart';
import 'package:ssurade/crawling/tasks/AllGradeByCategory.dart';
import 'package:ssurade/crawling/tasks/AllGradeBySemester.dart';
import 'package:ssurade/crawling/tasks/EntranceGraduateYear.dart';
import 'package:ssurade/crawling/tasks/LoginSession.dart';
import 'package:ssurade/crawling/tasks/SingleGrade.dart';
import 'package:ssurade/types/YearSemester.dart';
import 'package:ssurade/types/subject/SemesterSubjectsManager.dart';

class Crawler {
  Crawler._(); // do not create class

  static final WebViewWorker worker = WebViewWorker();

  static const LoginSession Function({ISentrySpan? parentTransaction}) loginSession = LoginSession.get;
  static const EntranceGraduateYear Function({ISentrySpan? parentTransaction}) entranceGraduateYear = EntranceGraduateYear.get;
  static const SingleGrade Function(YearSemester, {bool reloadPage, ISentrySpan? parentTransaction}) singleGrade = SingleGrade.get;
  static const AllGrade Function({SemesterSubjectsManager? base, ISentrySpan? parentTransaction}) allGrade = AllGrade.get;
  static const AllGradeByCategory Function({ISentrySpan? parentTransaction}) allGradeByCategory = AllGradeByCategory.get;
  static const AllGradeBySemester Function({int startYear, ISentrySpan? parentTransaction}) allGradeBySemester = AllGradeBySemester.get;
}
