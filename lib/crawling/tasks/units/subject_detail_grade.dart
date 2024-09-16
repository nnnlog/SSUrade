import 'dart:async';
import 'dart:collection';

import 'package:flutter_inappwebview/src/in_app_webview/in_app_webview_controller.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/crawler.dart';
import 'package:ssurade/crawling/common/crawling_task.dart';
import 'package:ssurade/crawling/common/webview_controller_extension.dart';
import 'package:ssurade/crawling/error/unauthenticated_exception.dart';
import 'package:ssurade/types/semester/year_semester.dart';

class SubjectDetailGrade extends CrawlingTask<Map<String, String>> {
  YearSemester search;
  String subjectCode;
  bool reloadPage;

  factory SubjectDetailGrade.get(
    YearSemester search,
    String subjectCode, {
    bool reloadPage = false,
    ISentrySpan? parentTransaction,
  }) =>
      SubjectDetailGrade._(search, subjectCode, reloadPage, parentTransaction);

  SubjectDetailGrade._(this.search, this.subjectCode, this.reloadPage, super.parentTransaction);

  @override
  String getTaskId() {
    return "subject_detail_grade";
  }

  @override
  int getTimeout() {
    return 20;
  }

  @override
  Future<Map<String, String>> internalExecute(Queue<InAppWebViewController> controllers, [Completer? onComplete]) async {
    var controller = controllers.removeFirst();

    final transaction = parentTransaction?.startChild(getTaskId()) ?? Sentry.startTransaction('SubjectDetailGrade', getTaskId());
    late ISentrySpan span;

    if (!(await Crawler.loginSession(parentTransaction: transaction).directExecute(Queue()..add(controller)))) {
      throw UnauthenticatedException();
    }

    span = transaction.startChild("check_url");
    var url = (await controller.getUrl()).toString();
    if (url.contains("#")) {
      url = url.substring(0, url.indexOf("#"));
    }
    span.finish(status: const SpanStatus.ok());

    if (reloadPage || url != "https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMB3W0017?sap-language=KO") {
      await controller.customLoadPage(
        "https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMB3W0017?sap-language=KO",
        parentTransaction: transaction,
        login: true,
      );
    }

    span = transaction.startChild("execute_js");
    var ret =
        (((await controller.callAsyncJavaScript(functionBody: "return await ssurade.crawl.getGradeDetail('${search.year}', '${search.semester.rawIntegerValue}', '$subjectCode').catch(() => {});"))!
                    .value) ??
                {"-": "성적이 입력되지 않았거나 상세 정보가 없어요."})
            .cast<String, String>();
    span.finish(status: const SpanStatus.ok());

    return ret;
  }
}
