import 'dart:convert';
import 'dart:developer';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ssurade/crawling/Crawler.dart';
import 'package:ssurade/crawling/CrawlingTask.dart';
import 'package:ssurade/crawling/WebViewControllerExtension.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/Progress.dart';
import 'package:ssurade/types/Semester.dart';
import 'package:ssurade/types/subject/Ranking.dart';
import 'package:ssurade/types/subject/SemesterSubjects.dart';
import 'package:ssurade/types/subject/Subject.dart';
import 'package:ssurade/types/subject/gradeTable.dart';

import '../types/YearSemester.dart';

class SingleGrade extends CrawlingTask<SemesterSubjects?> {
  YearSemester search;
  bool reloadPage;

  static SingleGrade get(
    YearSemester search, {
    bool reloadPage = true,
  }) {
    return SingleGrade._(search, reloadPage);
  }

  SingleGrade._(this.search, this.reloadPage);

  @override
  String task_id = "single_grade";

  @override
  Future<SemesterSubjects?> internalExecute(InAppWebViewController controller) async {
    bool isFinished = false;

    SemesterSubjects? result;
    try {
      result = await Future.any([
        Future(() async {
          if (!(await Crawler.loginSession().directExecute(controller))) {
            return null;
          }

          // DateTime time = DateTime.now();
          // showToast("start : ${search.toString()}");
          // log("start : ${search.toString()}");

          var url = (await controller.getUrl()).toString();
          if (url.contains("#")) {
            url = url.substring(0, url.indexOf("#"));
          }

          if (reloadPage || url != "https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMB3W0017?sap-language=KO") {
            await controller.initForXHR();
            // showToast("init (xhr) : ${DateTime.now().difference(time).inMilliseconds}ms");
            // log("init (xhr) : ${DateTime.now().difference(time).inMilliseconds}ms");
            // time = DateTime.now();

            await controller.loadUrl(urlRequest: URLRequest(url: Uri.parse("https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMB3W0017?sap-language=KO")));
            // showToast("load (page) : ${DateTime.now().difference(time).inMilliseconds}ms");
            // log("load (page) : ${DateTime.now().difference(time).inMilliseconds}ms");
            // time = DateTime.now();

            await controller.waitForXHR();
            // showToast("finishXHR : ${DateTime.now().difference(time).inMilliseconds}ms");
            // log("finishXHR : ${DateTime.now().difference(time).inMilliseconds}ms");
            // time = DateTime.now();

            // 도큐먼트가 완전히 로딩될 때까지 대기
            await Future.doWhile(() async {
              if (isFinished) return false;
              try {
                var selected = (await controller.evaluateJavascript(
                    source:
                        'document.querySelectorAll("table table table table")[12].querySelector("td:nth-child(2) span")?.querySelector("*[value]").value;'));
                if (selected == null) {
                  await Future.delayed(const Duration(milliseconds: 100));
                  return true;
                }
                return false;
              } catch (e) {
                return true;
              }
            });
          } else {
            await controller.initForXHR();
          }

          // log("xhr count : ${globals.webViewXHRTotalCount}");
          // log("xhr running count : ${globals.webViewXHRRunningCount}");

          // 학년도 드롭다운(dropdown)에서 학년도 선택
          controller.webViewXHRProgress = XHRProgress.ready;
          // log("start capture : year");
          bool existXHR = false;
          await Future.doWhile(() async {
            if (isFinished) return false;
            try {
              var selected = (await controller.evaluateJavascript(
                  source:
                      'document.querySelectorAll("table table table table")[12].querySelector("td:nth-child(2) span")?.querySelector("*[value]").value;'));
              if (selected == null) {
                await Future.delayed(const Duration(milliseconds: 100));
                return true;
              }
              if (selected?.replaceAll(" ", "") == "${search.year}학년도") return false;
              if (existXHR) return false;
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
              await Future.delayed(const Duration(milliseconds: 100));
              await controller.evaluateJavascript(source: 'document.querySelector("div[data-itemvalue1=\'${search.year}학년도\']").click();');
              await Future.delayed(const Duration(milliseconds: 100));
            } catch (e, s) {
              // showToast("error : ${e.toString()} (${s.toString()}");
              log(e.toString());
              log(s.toString());
            }
            return true;
          });
          // showToast("select year : ${DateTime.now().difference(time).inMilliseconds}ms");
          // log("select year : ${DateTime.now().difference(time).inMilliseconds}ms");
          // time = DateTime.now();

          if (existXHR) {
            await controller.waitForSingleXHRRequest();
            // showToast("load year : ${DateTime.now().difference(time).inMilliseconds}ms");
            // log("load year : ${DateTime.now().difference(time).inMilliseconds}ms");
            // time = DateTime.now();
          }

          // 학기 드롭다운(dropdown)에서 학기 선택
          controller.webViewXHRProgress = XHRProgress.ready;
          // log("start capture : semester");
          existXHR = false;
          await Future.doWhile(() async {
            if (isFinished) return false;
            try {
              var selected = await controller.evaluateJavascript(
                  source:
                      'document.querySelectorAll("table table table table")[12].querySelector("td:nth-child(5) span")?.querySelector("*[value]").value;');
              if (selected == null) {
                await Future.delayed(const Duration(milliseconds: 100));
                return true;
              }
              if (selected?.replaceAll(" ", "") == search.semester.name) return false;
              if (existXHR) return false;
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
              await Future.delayed(const Duration(milliseconds: 100));
              await controller.evaluateJavascript(
                  source:
                      'document.querySelector("div div div div:nth-child(3) div div:nth-child(2) div:nth-child(2) div div div:nth-child(${search.semester.webIndex})").click();');
              await Future.delayed(const Duration(milliseconds: 100));
            } catch (e, s) {
              // showToast("error : ${e.toString()} (${s.toString()}");
              log(e.toString());
              log(s.toString());
            }
            return true;
          });
          // showToast("select sem : ${DateTime.now().difference(time).inMilliseconds}ms");
          // log("select sem : ${DateTime.now().difference(time).inMilliseconds}ms");
          // time = DateTime.now();

          // 현재 학기 정보가 모두 로딩될 때까지 대기
          if (existXHR) {
            await controller.waitForSingleXHRRequest();
            // showToast("load sem : ${DateTime.now().difference(time).inMilliseconds}ms");
            // log("load sem : ${DateTime.now().difference(time).inMilliseconds}ms");
            // time = DateTime.now();
          }

          dynamic temp = "";
          await Future.any([
            Future.doWhile(() async {
              if (isFinished) return false;
              try {
                temp = await controller.evaluateJavascript(source: '''
                JSON.stringify(
                  Array(...document.querySelectorAll(`table tr table tr table tr:nth-child(11) td table table table table tbody:nth-child(2) tr`))
                    .slice(1).map(element => [
                      element.querySelector(`td:nth-child(4) span span`).textContent.trim(), // 과목 번호
                      element.querySelector(`td:nth-child(5) span span`).textContent.trim(), // 과목명
                      element.querySelector(`td:nth-child(6) span span`).textContent.trim(), // 학점 (이수 단위)
                      element.querySelector(`td:nth-child(8) span span`).textContent.trim(), // 학점 (등급)
                      element.querySelector(`td:nth-child(9) span span`).textContent.trim(), // 교수명
                    ]
                  )
                );
              ''');

                temp ??= "";
                temp = temp.trim();
                return temp.isEmpty;
              } catch (e, stacktrace) {
                log(e.toString());
                log(stacktrace.toString());
                await Future.delayed(const Duration(milliseconds: 100));
                return true;
              }
            }),
            Future.delayed(const Duration(seconds: 5))
          ]);
          // showToast("finish : ${DateTime.now().difference(time).inMilliseconds}ms");
          // log("finish : ${DateTime.now().difference(time).inMilliseconds}ms");
          // time = DateTime.now();

          Ranking semesterRanking = Ranking(0, 0), totalRanking = Ranking(0, 0);
          try {
            String temp = await controller.evaluateJavascript(source: '''
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

            var json = jsonDecode(temp);
            semesterRanking = Ranking.parse(json[0]);
            totalRanking = Ranking.parse(json[1]);
          } catch (e) {}

          temp = jsonDecode(temp);

          SemesterSubjects result = SemesterSubjects([], semesterRanking, totalRanking, search);
          for (var obj in temp) {
            result.subjects.add(Subject(obj[0], obj[1], double.parse(obj[2]), obj[3], obj[4]));
          }
          result.subjects.sort((a, b) {
            double x = gradeTable[a.grade] ?? -5;
            double y = gradeTable[b.grade] ?? -5;
            if (x != y) return x > y ? -1 : 1; // 등급(grade) 높은 것부터
            if (a.credit != b.credit) return a.credit > b.credit ? -1 : 1; // 학점(credit) 높은 것부터
            return a.name.compareTo(b.name);
          });

          await result.loadPassFailSubjects();
          return result;
        }),
        Future.delayed(Duration(seconds: globals.setting.timeoutGrade), () => null),
      ]);
    } catch (e, stacktrace) {
      log(e.toString());
      log(stacktrace.toString());

      return null;
    } finally {
      isFinished = true;
    }

    return result;
  }
}
