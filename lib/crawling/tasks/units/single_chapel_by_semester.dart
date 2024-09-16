import 'dart:async';
import 'dart:collection';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/crawling_task.dart';
import 'package:ssurade/crawling/common/webview_controller_extension.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/chapel/chapel.dart';
import 'package:ssurade/types/chapel/chapel_attendance.dart';
import 'package:ssurade/types/chapel/chapel_attendance_status.dart';
import 'package:ssurade/types/semester/year_semester.dart';
import 'package:ssurade_application/domain/model/error/no_data_exception.dart';

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
        login: true,
      );
    }

    span = transaction.startChild("execute_js");
    var res = (await controller.callAsyncJavaScript(functionBody: "return await ssurade.crawl.getChapelInformation('${search.year}', '${search.semester.rawIntegerValue}').catch(() => {});"))!.value;
    var summary = res["summary"];
    span.finish(status: const SpanStatus.ok());

    if (summary == null || res["attendance"].length == 0) throw EmptyDataException();

    span = transaction.startChild("finalizing_data");

    ChapelInformation result = ChapelInformation(search, SplayTreeSet(), summary["subject_code"], summary["subject_place"], summary["subject_time"], summary["floor"], summary["seat_no"]);
    for (var obj in res["attendance"]) {
      var data = ChapelAttendanceInformation(
        attendance: ChapelAttendance.from(obj["attendance"]),
        overwrittenAttendance: ChapelAttendance.unknown,
        affiliation: obj["affiliation"],
        lectureDate: obj["lecture_date"],
        lectureEtc: obj["lecture_etc"],
        lectureName: obj["lecture_name"],
        lectureType: obj["lecture_type"],
        lecturer: obj["lecturer"],
      );
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
