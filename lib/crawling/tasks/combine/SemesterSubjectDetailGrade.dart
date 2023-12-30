import 'dart:async';
import 'dart:collection';

import 'package:flutter_inappwebview/src/in_app_webview/in_app_webview_controller.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/Crawler.dart';
import 'package:ssurade/crawling/common/CrawlingTask.dart';
import 'package:ssurade/crawling/common/WebViewControllerExtension.dart';
import 'package:ssurade/crawling/error/UnauthenticatedExcpetion.dart';
import 'package:ssurade/types/subject/SemesterSubjects.dart';

class SemesterSubjectDetailGrade extends CrawlingTask<Map<String, Map<String, String>>> {
  SemesterSubjects manager;

  factory SemesterSubjectDetailGrade.get(
    SemesterSubjects manager, {
    ISentrySpan? parentTransaction,
  }) =>
      SemesterSubjectDetailGrade._(manager, parentTransaction);

  SemesterSubjectDetailGrade._(this.manager, super.parentTransaction);

  static const subjectCountPerController = 4;

  @override
  String getTaskId() {
    return "semester_subject_detail_grade";
  }

  @override
  int getTimeout() {
    return getWebViewCount() * 10 + subjectCountPerController * 10;
  }

  @override
  int getWebViewCount() {
    int cnt = manager.subjects.length;
    return cnt ~/ subjectCountPerController + (cnt % subjectCountPerController > 0 ? 1 : 0);
  }

  @override
  Future<Map<String, Map<String, String>>> internalExecute(Queue<InAppWebViewController> controllers, [Completer? onComplete]) async {
    assert(controllers.length == getWebViewCount());

    final transaction = parentTransaction?.startChild(getTaskId()) ?? Sentry.startTransaction('SemesterSubjectDetailGrade', getTaskId());
    late ISentrySpan span;

    var subjects = Queue()..addAll(manager.subjects.values.map((e) => e.code));

    span = transaction.startChild("login_execute_js");
    Map<String, Map<String, String>> ret = {};
    List<Future> futures = [];
    while (controllers.isNotEmpty) {
      var completer = Completer();
      futures.add(completer.future);

      var controller = controllers.removeFirst();
      var inputs = [];
      for (int j = 0; j < subjectCountPerController && subjects.isNotEmpty; j++) {
        inputs.add(subjects.removeFirst());
      }

      (() async {
        if (!(await Crawler.loginSession(parentTransaction: transaction).directExecute(Queue()..add(controller)))) {
          throw UnauthenticatedException();
        }

        await controller.customLoadPage(
          "https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMB3W0017?sap-language=KO",
          parentTransaction: transaction,
        );

        for (var code in inputs) {
          ret[code] = await Crawler.subjectDetailGrade(manager.currentSemester, code, parentTransaction: transaction).directExecute(Queue()..add(controller));
        }

        completer.complete();
      })();
    }

    await Future.wait(futures);

    span.finish(status: const SpanStatus.ok());
    transaction.finish(status: const SpanStatus.ok());

    return ret;
  }
}
