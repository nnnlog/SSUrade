import 'dart:async';
import 'dart:collection';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/crawler.dart';
import 'package:ssurade/crawling/common/crawling_task.dart';
import 'package:ssurade/crawling/common/webview_controller_extension.dart';
import 'package:ssurade/crawling/error/no_data_exception.dart';
import 'package:ssurade/crawling/error/unauthenticated_exception.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/absent/absent_application_information.dart';
import 'package:ssurade/types/semester/year_semester.dart';

class SingleAbsentBySemester extends CrawlingTask<List<AbsentApplicationInformation>> {
  YearSemester? search;
  bool reloadPage;

  factory SingleAbsentBySemester.get({
    YearSemester? search,
    bool reloadPage = false,
    ISentrySpan? parentTransaction,
  }) =>
      SingleAbsentBySemester._(search, reloadPage, parentTransaction);

  SingleAbsentBySemester._(this.search, this.reloadPage, ISentrySpan? parentTransaction) : super(parentTransaction);

  @override
  Future<List<AbsentApplicationInformation>> internalExecute(Queue<InAppWebViewController> controllers, [Completer? onComplete]) async {
    var controller = controllers.removeFirst();

    final transaction = parentTransaction?.startChild(getTaskId()) ?? Sentry.startTransaction('SingleAbsentBySemester', getTaskId());
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

    if (reloadPage || url != "https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW3683?sap-language=KO") {
      await controller.customLoadPage(
        "https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW3683?sap-language=KO",
        parentTransaction: transaction,
      );
    }

    span = transaction.startChild("execute_js");
    var res = (await controller.callAsyncJavaScript(
            functionBody: "return await ssurade.crawl.getAbsentApplicationInformation(${search == null ? "" : "'${search!.year}', '${search!.semester.keyValue}'"}).catch(() => {});"))!
        .value;
    span.finish(status: const SpanStatus.ok());

    if (res == null) throw NoDataException();

    span = transaction.startChild("finalizing_data");

    List<AbsentApplicationInformation> result = [];
    for (var obj in res) {
      result.add(AbsentApplicationInformation(
        obj['absent_type'],
        obj['start_date'],
        obj['end_date'],
        obj['absent_cause'],
        obj['application_date'],
        obj['proceed_date'],
        obj['reject_cause'],
        obj['status'],
      ));
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
    return "single_absent_by_semester";
  }
}
