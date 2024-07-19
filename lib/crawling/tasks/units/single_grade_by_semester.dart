import 'dart:async';
import 'dart:collection';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/crawler.dart';
import 'package:ssurade/crawling/common/crawling_task.dart';
import 'package:ssurade/crawling/common/webview_controller_extension.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/semester/year_semester.dart';
import 'package:ssurade/types/subject/ranking.dart';
import 'package:ssurade/types/subject/semester_subjects.dart';
import 'package:ssurade/types/subject/subject.dart';

class SingleGradeBySemester extends CrawlingTask<SemesterSubjects> {
  YearSemester search;
  bool reloadPage;
  bool getRanking;
  Queue<InAppWebViewController>? _subControllers;

  factory SingleGradeBySemester.get(
    YearSemester search, {
    bool reloadPage = false,
    bool getRanking = true,
    Queue<InAppWebViewController>? subControllers,
    ISentrySpan? parentTransaction,
  }) =>
      SingleGradeBySemester._(search, reloadPage, getRanking, subControllers, parentTransaction);

  SingleGradeBySemester._(this.search, this.reloadPage, this.getRanking, this._subControllers, ISentrySpan? parentTransaction) : super(parentTransaction);

  @override
  Future<SemesterSubjects> internalExecute(Queue<InAppWebViewController> controllers, [Completer? onComplete]) async {
    var controller = controllers.removeFirst();

    final transaction = parentTransaction?.startChild(getTaskId()) ?? Sentry.startTransaction('SingleGrade', getTaskId());
    late ISentrySpan span;

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
    var res = (await controller.callAsyncJavaScript(
            functionBody: "return await ssurade.crawl.getGradeBySemester('${search.year}', '${search.semester.keyValue}', '${search.semester.textValue}', ${getRanking.toString()}).catch(() => {});"))!
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
      if (obj["grade_symbol"] == "성적 미입력") {
        obj["grade_symbol"] = "";
      }
      var data = Subject(obj["subject_code"], obj["subject_name"], double.parse(obj["credit"]), obj["grade_symbol"], obj["grade_score"], obj["professor"], "", false, "");
      result.subjects[data.code] = data;
    }

    if (result.subjects.isEmpty) {
      if (_subControllers == null || _subControllers!.isEmpty) {
        result.subjects = (await Crawler.singleGradeBySemesterOldVersion(search, parentTransaction: transaction).execute()).subjects;
      } else {
        result.subjects = (await Crawler.singleGradeBySemesterOldVersion(search, parentTransaction: transaction).directExecute(_subControllers!)).subjects;
      }
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
