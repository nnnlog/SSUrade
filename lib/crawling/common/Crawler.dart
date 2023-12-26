import 'package:ssurade/crawling/common/WebViewWorker.dart';
import 'package:ssurade/crawling/tasks/combine/AllGrade.dart';
import 'package:ssurade/crawling/tasks/combine/AllGradeByCategory.dart';
import 'package:ssurade/crawling/tasks/combine/AllGradeBySemester.dart';
import 'package:ssurade/crawling/tasks/units/ExtractDataFromViewer.dart';
import 'package:ssurade/crawling/tasks/units/GradeSemesterList.dart';
import 'package:ssurade/crawling/tasks/units/LoginSession.dart';
import 'package:ssurade/crawling/tasks/units/SingleGradeBySemester.dart';
import 'package:ssurade/crawling/tasks/units/WebUrlByCategory.dart';

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
  static const singleGrade = SingleGrade.get;
}
