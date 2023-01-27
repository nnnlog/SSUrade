import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/Crawler.dart';
import 'package:ssurade/crawling/CrawlingTask.dart';
import 'package:ssurade/crawling/ExtractDataFromViewer.dart';
import 'package:ssurade/crawling/WebViewControllerExtension.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/Progress.dart';
import 'package:ssurade/types/Semester.dart';
import 'package:ssurade/types/YearSemester.dart';
import 'package:ssurade/types/subject/Ranking.dart';
import 'package:ssurade/types/subject/SemesterSubjects.dart';
import 'package:ssurade/types/subject/SemesterSubjectsManager.dart';
import 'package:ssurade/types/subject/Subject.dart';

class AllGradeByCategory extends CrawlingTask<SemesterSubjectsManager?> {
  static final AllGradeByCategory _instance = AllGradeByCategory._();

  factory AllGradeByCategory.get() {
    return _instance;
  }

  AllGradeByCategory._();

  @override
  String task_id = "all_grade_by_category";

  @override
  Future<SemesterSubjectsManager?> internalExecute(InAppWebViewController controller) async {
    bool isFinished = false;

    SemesterSubjectsManager? result;
    try {
      result = await Future.any([
        Future(() async {
          if (!(await Crawler.loginSession().directExecute(controller))) {
            return null;
          }

          result = SemesterSubjectsManager(SplayTreeMap.from({}));

          controller.initForXHR();

          await controller.loadUrl(urlRequest: URLRequest(url: Uri.parse("https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW8030n?sap-language=KO")));

          await controller.waitForXHR();

          Completer<void> com1 = Completer(), com2 = Completer();
          controller.jsRedirectCallback = (url) {
            (() async {
              await com1.future; // xhr 요청이 끝날 때까지 먼저 기다린다.

              controller.initForXHR();
              await controller.evaluateJavascript(source: "location.replace(atob('${base64Encode(utf8.encode(url))}'));");
              await Future.doWhile(controller.isLoading);
              await controller.waitForXHR();
              com2.complete();
            })();
          };

          controller.webViewXHRProgress = XHRProgress.ready;
          await controller.evaluateJavascript(source: """
              document.evaluate("//span[normalize-space()='이수구분별 성적현황 출력 인쇄']", document, null, XPathResult.ANY_TYPE, null ).iterateNext().click();
            """);
          await controller.waitForSingleXHRRequest();
          com1.complete();
          await com2.future; // 페이지 리다이렉션 후 xhr 요청이 완료될 때까지 기다린다.

          var gradeData = await extractDataFromViewer(controller);
          if (gradeData == null) throw Exception("[AllGrade.dart] extractDataFromViewer returns null");

          var tmp = SemesterSubjectsManager(SplayTreeMap());
          for (var _data in gradeData.rows) {
            Map<String, String> data = {};
            for (var key in _data.keys) {
              data[key] = _data[key] as String;
            }

            var rawKey = data["HUKGI"]!.split("―"); // format: 2022―1, 2022―겨울
            var key = YearSemester(int.parse(rawKey[0]), Semester.parse("${rawKey[1]}학기"));

            tmp.data[key] ??= SemesterSubjects(SplayTreeMap(), Ranking(0, 0), Ranking(0, 0), key);

            var category = data["COMPL_TEXT"]!;
            var credit = double.parse(data["CPATTEMP"]!);
            var grade = data["GRADE"]!;
            var isPassFail = data["GRADESCALE"]! == "PF"; // otherwise, '100P'
            // var code = data["SE_SHORT"]!.replaceAll(RegExp("\\(|\\)"), ""); // FORMAT: 21501015(06) - 괄호 안은 분반 정보
            var code = data["SM_ID"]!; // FORMAT: 21501015
            // SUBJECT NAME (SM_TEXT에 존재하지만, 교선에 교선 분류명도 함께 있음)
            // PROF NAME (not exist)

            var subject = Subject(code, "", credit, grade, "", category, isPassFail, Subject.STATE_CATEGORY);
            tmp.data[key]!.subjects[subject.code] = subject;
          }

          // log(tmp.toString());
          // showToast(tmp.toString());

          return result = tmp;
        }),
        Future.delayed(Duration(seconds: globals.setting.timeoutAllGrade), () => null),
      ]);
    } catch (e, stacktrace) {
      log(e.toString());
      log(stacktrace.toString());

      Sentry.captureException(
        e,
        stackTrace: stacktrace,
      );

      return null;
    } finally {
      isFinished = true;
    }

    return result;
  }
}
