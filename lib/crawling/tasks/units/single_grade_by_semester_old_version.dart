import 'dart:async';
import 'dart:collection';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/crawler.dart';
import 'package:ssurade/crawling/common/crawling_task.dart';
import 'package:ssurade/crawling/common/webview_controller_extension.dart';
import 'package:ssurade/crawling/error/unauthenticated_exception.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/semester/year_semester.dart';
import 'package:ssurade/types/subject/ranking.dart';
import 'package:ssurade/types/subject/semester_subjects.dart';
import 'package:ssurade/types/subject/subject.dart';

class SingleGradeBySemesterOldVersion extends CrawlingTask<SemesterSubjects> {
  YearSemester search;
  bool reloadPage;

  factory SingleGradeBySemesterOldVersion.get(
    YearSemester search, {
    bool reloadPage = false,
    ISentrySpan? parentTransaction,
  }) =>
      SingleGradeBySemesterOldVersion._(search, reloadPage, parentTransaction);

  SingleGradeBySemesterOldVersion._(this.search, this.reloadPage, ISentrySpan? parentTransaction) : super(parentTransaction);

  @override
  Future<SemesterSubjects> internalExecute(Queue<InAppWebViewController> controllers, [Completer? onComplete]) async {
    var controller = controllers.removeFirst();

    final transaction = parentTransaction?.startChild(getTaskId()) ?? Sentry.startTransaction('SingleGradeOldVersion', getTaskId());
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

    if (reloadPage || url != "https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW5002?sap-language=KO") {
      await controller.customLoadPage(
        "https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW5002?sap-language=KO",
        parentTransaction: transaction,
      );
    }

    span = transaction.startChild("execute_js");
    var res = (await controller.callAsyncJavaScript(functionBody: "return await ssurade.crawl.getGradeBySemesterOldVersion('${search.year}', '${search.semester.keyValue}').catch(() => {});"))!.value;
    span.finish(status: const SpanStatus.ok());

    SemesterSubjects result = SemesterSubjects(SplayTreeMap(), search, Ranking.unknown, Ranking.unknown);
    for (var obj in res["subjects"]) {
      var data = Subject(obj["subject_code"], obj["subject_name"], 0, "", "", obj["professor"], "", false, "");
      result.subjects[data.code] = data;
    }
    span.finish(status: const SpanStatus.ok());

    return result;
  }

  @override
  int getTimeout() {
    return globals.setting.timeoutGrade;
  }

  @override
  String getTaskId() {
    return "single_grade_by_semester_old_version";
  }
}
