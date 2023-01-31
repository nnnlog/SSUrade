import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/AllGrade.dart';
import 'package:ssurade/crawling/AllGradeByCategory.dart';
import 'package:ssurade/crawling/AllGradeBySemester.dart';
import 'package:ssurade/crawling/EntranceGraduateYear.dart';
import 'package:ssurade/crawling/LoginSession.dart';
import 'package:ssurade/crawling/SingleGrade.dart';
import 'package:ssurade/crawling/WebViewWorker.dart';
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
