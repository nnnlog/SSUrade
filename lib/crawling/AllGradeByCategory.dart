import 'dart:async';
import 'dart:collection';
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
  factory AllGradeByCategory.get({
    ISentrySpan? parentTransaction,
  }) =>
      AllGradeByCategory._(parentTransaction);

  AllGradeByCategory._(ISentrySpan? parentTransaction) : super(parentTransaction);

  @override
  String task_id = "all_grade_by_category";

  @override
  Future<SemesterSubjectsManager?> internalExecute(InAppWebViewController controller) async {
    final transaction = parentTransaction == null ? Sentry.startTransaction('AllGradeByCategory', task_id) : parentTransaction!.startChild(task_id);
    late ISentrySpan span;

    SemesterSubjectsManager? result;
    try {
      result = await Future.any([
        Future(() async {
          if (!(await Crawler.loginSession(parentTransaction: transaction).directExecute(controller))) {
            return null;
          }

          result = SemesterSubjectsManager(SplayTreeMap.from({}));

          await controller.customLoadPage("https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW8030n?sap-language=KO", parentTransaction: transaction);

          Completer<void> com1 = Completer(), com2 = Completer();
          controller.jsRedirectCallback = (url) {
            (() async {
              await com1.future; // xhr 요청이 끝날 때까지 먼저 기다린다.
              await controller.customLoadPage(url, parentTransaction: transaction);
              com2.complete();
            })();
          };

          span = transaction.startChild("click_print_btn");
          while (await controller.evaluateJavascript(source: """
              document.evaluate("//span[normalize-space()='이수구분별 성적현황 출력 인쇄']", document, null, XPathResult.ANY_TYPE, null ).iterateNext();
            """) == null) {
          }
          controller.webViewXHRProgress = XHRProgress.ready;
          await controller.evaluateJavascript(source: """
              document.evaluate("//span[normalize-space()='이수구분별 성적현황 출력 인쇄']", document, null, XPathResult.ANY_TYPE, null ).iterateNext().click();
            """);
          await controller.waitForSingleXHRRequest();
          com1.complete();
          span.finish(status: const SpanStatus.ok());

          await com2.future; // 페이지 리다이렉션 후 xhr 요청이 완료될 때까지 기다린다.

          var gradeData = await extractDataFromViewer(controller, parentTransaction: transaction);

          span = transaction.startChild("finalizing_data");
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
          span.finish(status: const SpanStatus.ok());

          // log(tmp.toString());
          // showToast(tmp.toString());

          return result = tmp;
        }),
        Future.delayed(Duration(seconds: globals.setting.timeoutAllGrade), () => null),
      ]);
    } catch (e, stacktrace) {
      log(e.toString());
      log(stacktrace.toString());

      transaction.throwable = e;
      Sentry.captureException(
        e,
        stackTrace: stacktrace,
        withScope: (scope) {
          scope.span = transaction;
          scope.level = SentryLevel.error;
        },
      );

      return null;
    } finally {
      transaction.status = result != null ? const SpanStatus.ok() : const SpanStatus.internalError();
      await transaction.finish();
    }

    return result;
  }
}
