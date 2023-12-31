import 'dart:async';
import 'dart:collection';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/Crawler.dart';
import 'package:ssurade/crawling/common/CrawlingTask.dart';
import 'package:ssurade/crawling/common/WebViewControllerExtension.dart';
import 'package:ssurade/crawling/error/UnauthenticatedExcpetion.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/chapel/ChapelAttendanceInformation.dart';
import 'package:ssurade/types/chapel/ChapelInformation.dart';
import 'package:ssurade/types/chapel/chapel_attendance.dart';
import 'package:ssurade/types/semester/YearSemester.dart';

class SingleChapelBySemester extends CrawlingTask<ChapelInformation> {
  YearSemester search;
  bool reloadPage;

  factory SingleChapelBySemester.get(
    YearSemester search, {
    bool reloadPage = false,
    ISentrySpan? parentTransaction,
  }) =>
      SingleChapelBySemester._(search, reloadPage, parentTransaction);

  SingleChapelBySemester._(this.search, this.reloadPage, ISentrySpan? parentTransaction) : super(parentTransaction);

  @override
  Future<ChapelInformation> internalExecute(Queue<InAppWebViewController> controllers, [Completer? onComplete]) async {
    var controller = controllers.removeFirst();

    final transaction = parentTransaction?.startChild(getTaskId()) ?? Sentry.startTransaction('SingleChapelBySemester', getTaskId());
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

    if (reloadPage || url != "https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW3681?sap-language=KO") {
      await controller.customLoadPage(
        "https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW3681?sap-language=KO",
        parentTransaction: transaction,
      );
    }

    span = transaction.startChild("execute_js");
    var res = (await controller.callAsyncJavaScript(functionBody: "return await ssurade.crawl.getChapelInformation('${search.year}', '${search.semester.keyValue}');"))!.value;
    var summary = res["summary"];
    span.finish(status: const SpanStatus.ok());

    span = transaction.startChild("finalizing_data");

    ChapelInformation result = ChapelInformation(search, SplayTreeSet(), summary["subject_code"], summary["subject_place"], summary["subject_time"], summary["floor"], summary["seat_no"]);
    for (var obj in res["attendance"]) {
      var data = ChapelAttendanceInformation(
          ChapelAttendance.from(obj["attendance"]), ChapelAttendance.unknown, obj["lecture_date"], obj["lecture_etc"], obj["lecture_name"], obj["lecture_type"], obj["lecturer"]);
      result.attendances.add(data);
    }
    span.finish(status: const SpanStatus.ok());

    return result;
  }

  @override
  int getTimeout() {
    return globals.setting.timeoutGrade; // TODO: change
  }

  @override
  String getTaskId() {
    return "single_chapel_by_semester";
  }
}
