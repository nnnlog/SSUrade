import 'dart:async';
import 'dart:collection';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/Crawler.dart';
import 'package:ssurade/crawling/common/CrawlingTask.dart';
import 'package:ssurade/crawling/common/WebViewControllerExtension.dart';
import 'package:ssurade/crawling/error/UnauthenticatedExcpetion.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/semester/YearSemester.dart';
import 'package:ssurade/types/subject/Ranking.dart';
import 'package:ssurade/types/subject/SemesterSubjects.dart';
import 'package:ssurade/types/subject/Subject.dart';

class SingleGradeBySemester extends CrawlingTask<SemesterSubjects> {
  YearSemester search;
  bool reloadPage;
  bool getRanking;

  factory SingleGradeBySemester.get(
    YearSemester search, {
    bool reloadPage = false,
    bool getRanking = true,
    ISentrySpan? parentTransaction,
  }) =>
      SingleGradeBySemester._(search, reloadPage, getRanking, parentTransaction);

  SingleGradeBySemester._(this.search, this.reloadPage, this.getRanking, ISentrySpan? parentTransaction) : super(parentTransaction);

  @override
  Future<SemesterSubjects> internalExecute(Queue<InAppWebViewController> controllers, [Completer? onComplete]) async {
    var controller = controllers.removeFirst();

    final transaction = parentTransaction?.startChild(getTaskId()) ?? Sentry.startTransaction('SingleGrade', getTaskId());
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
      );
    }

    span = transaction.startChild("execute_js");
    var res = (await controller.callAsyncJavaScript(
            functionBody: "return await ssurade.crawl.getGradeBySemester('${search.year}', '${search.semester.keyValue}', '${search.semester.textValue}', ${getRanking.toString()});"))!
        .value;
    span.finish(status: const SpanStatus.ok());

    span = transaction.startChild("finalizing_data");
    Ranking semesterRanking = Ranking.unknown, totalRanking = Ranking.unknown;
    if (getRanking) {
      semesterRanking = Ranking.parse(res["rank"]?["semester_rank"] ?? "");
      totalRanking = Ranking.parse(res["rank"]?["total_rank"] ?? "");
    }

    SemesterSubjects result = SemesterSubjects(SplayTreeMap(), search, semesterRanking, totalRanking);
    for (var obj in res["subjects"]) {
      var data = Subject(obj["subject_code"], obj["subject_name"], double.parse(obj["credit"]), obj["grade_symbol"], obj["grade_score"], obj["professor"], "", false, "");
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
    return "single_grade_by_semester";
  }
}
