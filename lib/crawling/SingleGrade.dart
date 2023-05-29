import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/Crawler.dart';
import 'package:ssurade/crawling/CrawlingTask.dart';
import 'package:ssurade/crawling/WebViewControllerExtension.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/Progress.dart';
import 'package:ssurade/types/Semester.dart';
import 'package:ssurade/types/subject/Ranking.dart';
import 'package:ssurade/types/subject/SemesterSubjects.dart';
import 'package:ssurade/types/subject/Subject.dart';

import '../types/YearSemester.dart';

class SingleGrade extends CrawlingTask<SemesterSubjects?> {
  YearSemester search;
  bool reloadPage;

  factory SingleGrade.get(
    YearSemester search, {
    bool reloadPage = false,
    ISentrySpan? parentTransaction,
  }) =>
      SingleGrade._(search, reloadPage, parentTransaction);

  SingleGrade._(this.search, this.reloadPage, ISentrySpan? parentTransaction) : super(parentTransaction);

  @override
  String task_id = "single_grade";

  @override
  Future<SemesterSubjects?> internalExecute(InAppWebViewController controller) async {
    final transaction = parentTransaction == null ? Sentry.startTransaction('SingleGrade', task_id) : parentTransaction!.startChild(task_id);
    late ISentrySpan span;

    SemesterSubjects? result;
    try {
      result = await Future.any([
        Future(() async {
          if (!(await Crawler.loginSession(parentTransaction: transaction).directExecute(controller))) {
            return null;
          }

          span = transaction.startChild("check_url");
          var url = (await controller.getUrl()).toString();
          if (url.contains("#")) {
            url = url.substring(0, url.indexOf("#"));
          }
          span.finish(status: const SpanStatus.ok());

          if (reloadPage || url != "https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMB3W0017?sap-language=KO") {
            await controller.customLoadPage("https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMB3W0017?sap-language=KO", parentTransaction: transaction);
          }

          // 연도 선택
          span = transaction.startChild("select_year");
          controller.webViewXHRProgress = XHRProgress.ready;
          bool existXHR = false;
          l1:
          try {
            while (await controller.evaluateJavascript(source: """document.querySelectorAll("table table table table")[12].querySelector("td:nth-child(2) span")?.querySelector("*[value]").value;""") == null) {
              await Future.delayed(Duration.zero);
            }
            var selected = (await controller.evaluateJavascript(
                source:
                    'document.querySelectorAll("table table table table")[12].querySelector("td:nth-child(2) span")?.querySelector("*[value]").value;'));
            if (selected!.replaceAll(" ", "") == "${search.year}학년도") break l1;
            existXHR = true;

            if (await controller.evaluateJavascript(source: '''
              document.evaluate("//span[normalize-space()='닫기']", document, null, XPathResult.ANY_TYPE, null ).iterateNext()
              ''') != null) {
              await controller.evaluateJavascript(source: '''
              document.evaluate("//span[normalize-space()='닫기']", document, null, XPathResult.ANY_TYPE, null ).iterateNext()?.click();
              ''');
              await controller.waitForSingleXHRRequest();
              controller.webViewXHRProgress = XHRProgress.ready;
            }

            await controller.evaluateJavascript(
                source: 'document.querySelectorAll("table table table table")[12].querySelector("td:nth-child(2) span").click();');
            // await Future.delayed(const Duration(milliseconds: 10));
            await controller.evaluateJavascript(source: 'document.querySelector("div[data-itemvalue1=\'${search.year}학년도\']").click();');
            // await Future.delayed(const Duration(milliseconds: 10));
          } catch (e, s) {
            log(e.toString());
            log(s.toString());

            span.throwable = e;
            Sentry.captureException(
              e,
              stackTrace: s,
              withScope: (scope) {
                scope.span = span;
                scope.level = SentryLevel.error;
              },
            );
            span.finish(status: const SpanStatus.internalError());

            return null;
          }
          span.finish(status: const SpanStatus.ok());

          if (existXHR) {
            span = transaction.startChild("select_year_xhr");
            await controller.waitForSingleXHRRequest();
            span.finish(status: const SpanStatus.ok());
          }

          // 학기 선택
          span = transaction.startChild("select_semester");
          controller.webViewXHRProgress = XHRProgress.ready;
          existXHR = false;
          l2:
          try {
            while (await controller.evaluateJavascript(source: """document.querySelectorAll("table table table table")[12].querySelector("td:nth-child(5) span")?.querySelector("*[value]").value;""") == null) {
              await Future.delayed(Duration.zero);
            }
            var selected = await controller.evaluateJavascript(
                source:
                    'document.querySelectorAll("table table table table")[12].querySelector("td:nth-child(5) span")?.querySelector("*[value]").value;');
            if (selected!.replaceAll(" ", "") == search.semester.name) break l2;
            existXHR = true;

            if (await controller.evaluateJavascript(source: '''
              document.evaluate("//span[normalize-space()='닫기']", document, null, XPathResult.ANY_TYPE, null ).iterateNext()
              ''') != null) {
              await controller.evaluateJavascript(source: '''
              document.evaluate("//span[normalize-space()='닫기']", document, null, XPathResult.ANY_TYPE, null ).iterateNext()?.click();
              ''');
              await controller.waitForSingleXHRRequest();
              controller.webViewXHRProgress = XHRProgress.ready;
            }

            await controller.evaluateJavascript(
                source: 'document.querySelectorAll("table table table table")[12].querySelector("td:nth-child(5) span").click();');
            // await Future.delayed(const Duration(milliseconds: 10));
            await controller.evaluateJavascript(
                source:
                    'document.querySelector("div div div div:nth-child(3) div div:nth-child(2) div:nth-child(2) div div div:nth-child(${search.semester.webIndex})").click();');
            // await Future.delayed(const Duration(milliseconds: 10));
          } catch (e, s) {
            log(e.toString());
            log(s.toString());

            span.throwable = e;
            Sentry.captureException(
              e,
              stackTrace: s,
              withScope: (scope) {
                scope.span = span;
                scope.level = SentryLevel.error;
              },
            );
            span.finish(status: const SpanStatus.internalError());

            return null;
          }
          span.finish(status: const SpanStatus.ok());

          if (existXHR) {
            span = transaction.startChild("select_semester_xhr");
            await controller.waitForSingleXHRRequest();
            span.finish(status: const SpanStatus.ok());
          }

          span = transaction.startChild("get_grade");
          dynamic temp = await controller.evaluateJavascript(source: '''
                JSON.stringify(
                  Array(...document.querySelectorAll(`table tr table tr table tr:nth-child(11) td table table table table tbody:nth-child(2) tr`))
                    .slice(1).filter(element => element.querySelector(`td:nth-child(4) span span`) !== null).map(element => [
                      element.querySelector(`td:nth-child(4) span span`).textContent.trim(), // 과목 번호
                      element.querySelector(`td:nth-child(5) span span`).textContent.trim(), // 과목명
                      element.querySelector(`td:nth-child(6) span span`).textContent.trim(), // 학점 (이수 단위)
                      element.querySelector(`td:nth-child(8) span span`).textContent.trim(), // 학점 (등급)
                      element.querySelector(`td:nth-child(9) span span`).textContent.trim(), // 교수명
                    ]
                  )
                );
              ''');
          span.finish(status: const SpanStatus.ok());

          span = transaction.startChild("get_rank");
          Ranking semesterRanking = Ranking(0, 0), totalRanking = Ranking(0, 0);
          l3:
          try {
            String? temp = await controller.evaluateJavascript(source: '''
            JSON.stringify(
              Array(
                ...document.querySelectorAll("table tbody tr td table tbody tr td table tbody tr:nth-child(4) table tr table tbody tr table tbody td:nth-child(1) table tbody tr")
              ).slice(1).filter(e => 
                  e.querySelector("td:nth-child(2)").innerText === "${search.year}" && 
                  e.querySelector("td:nth-child(3)").innerText.replace(/\\ /g, "") === "${search.semester.name}"
              ).map(e => [
                  e.querySelector("td:nth-child(10)").innerText,
                  e.querySelector("td:nth-child(11)").innerText
              ])[0]
            );
            ''');
            if (temp == null) break l3;

            var json = jsonDecode(temp);
            semesterRanking = Ranking.parse(json[0]);
            totalRanking = Ranking.parse(json[1]);
          } catch (e, s) {
            span.throwable = e;
            Sentry.captureException(
              e,
              stackTrace: s,
              withScope: (scope) {
                scope.span = span;
                scope.level = SentryLevel.error;
              },
            );
            span.finish(status: const SpanStatus.internalError());

            return null;
          }
          span.finish(status: semesterRanking.isEmpty || totalRanking.isEmpty ? const SpanStatus.unavailable() : const SpanStatus.ok());

          span = transaction.startChild("finalizing_data");
          temp = jsonDecode(temp);

          SemesterSubjects result = SemesterSubjects(SplayTreeMap(), semesterRanking, totalRanking, search);
          for (var obj in temp) {
            var data = Subject(obj[0], obj[1], double.parse(obj[2]), obj[3], obj[4], "", false, Subject.STATE_SEMESTER);
            result.subjects[data.code] = data;
          }
          span.finish(status: const SpanStatus.ok());

          return result;
        }),
        Future.delayed(Duration(seconds: globals.setting.timeoutGrade), () => null),
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
      transaction.finish();
    }

    return result;
  }
}
