import 'dart:async';
import 'dart:collection';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/crawling_task.dart';
import 'package:ssurade/crawling/common/webview_controller_extension.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/scholarship/scholarship.dart';
import 'package:ssurade/types/scholarship/scholarship_manager.dart';
import 'package:ssurade/types/semester/semester.dart';
import 'package:ssurade/types/semester/year_semester.dart';

class GetScholarship extends CrawlingTask<ScholarshipManager> {
  factory GetScholarship.get({
    ISentrySpan? parentTransaction,
  }) =>
      GetScholarship._(parentTransaction);

  GetScholarship._(super.parentTransaction);

  @override
  Future<ScholarshipManager> internalExecute(Queue<InAppWebViewController> controllers, [Completer? onComplete]) async {
    var controller = controllers.removeFirst();

    final transaction = parentTransaction?.startChild(getTaskId()) ?? Sentry.startTransaction('GetScholarship', getTaskId());
    late ISentrySpan span;

    span = transaction.startChild("check_url");
    var url = (await controller.getUrl()).toString();
    if (url.contains("#")) {
      url = url.substring(0, url.indexOf("#"));
    }
    span.finish(status: const SpanStatus.ok());

    await controller.customLoadPage(
      "https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW7530n?sap-language=KO",
      parentTransaction: transaction,
      login: true,
    );

    span = transaction.startChild("execute_js");
    var res = (await controller.callAsyncJavaScript(functionBody: "return await ssurade.crawl.getScholarshipInformation().catch(() => {});"))!.value;
    span.finish(status: const SpanStatus.ok());

    span = transaction.startChild("finalizing_data");

    ScholarshipManager result = ScholarshipManager([]);
    for (var obj in res) {
      var data = Scholarship(YearSemester(int.parse(obj["year"]), Semester.parse(obj["semester"])), obj["name"], obj["process"], obj["price"]);
      result.data.add(data);
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
    return "get_scholarship";
  }
}
