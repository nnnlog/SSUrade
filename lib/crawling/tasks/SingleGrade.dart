import 'dart:collection';
import 'dart:developer';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/Crawler.dart';
import 'package:ssurade/crawling/common/CrawlingTask.dart';
import 'package:ssurade/crawling/common/WebViewControllerExtension.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/Semester.dart';
import 'package:ssurade/types/subject/Ranking.dart';
import 'package:ssurade/types/subject/SemesterSubjects.dart';
import 'package:ssurade/types/subject/Subject.dart';

import '../../types/YearSemester.dart';

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
            await controller.customLoadPage(
              "https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMB3W0017?sap-language=KO",
              parentTransaction: transaction,
              clear: true,
            );
          }

          span = transaction.startChild("execute_js");
          var res = (await controller.callAsyncJavaScript(functionBody: "return await ssurade.crawl.getSingleGrade('${search.year}', '${search.semester.keyValue}', '${search.semester.textValue}');"))!
              .value;
          span.finish(status: const SpanStatus.ok());

          span = transaction.startChild("finalizing_data");
          Ranking semesterRanking, totalRanking;
          semesterRanking = Ranking.parse(res["rank"]?["semester_rank"] ?? "-");
          totalRanking = Ranking.parse(res["rank"]?["total_rank"] ?? "-");

          SemesterSubjects result = SemesterSubjects(SplayTreeMap(), semesterRanking, totalRanking, search);
          for (var obj in res["subjects"]) {
            var data = Subject(obj["subject_code"], obj["subject_name"], double.parse(obj["credit"]), obj["grade_symbol"], obj["professor"], "", false, Subject.STATE_SEMESTER);
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
