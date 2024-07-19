import 'dart:async';
import 'dart:collection';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/crawling_task.dart';
import 'package:ssurade/crawling/common/webview_controller_extension.dart';
import 'package:ssurade/globals.dart' as globals;

class WebUrlByCategory extends CrawlingTask<String> {
  factory WebUrlByCategory.get({
    ISentrySpan? parentTransaction,
  }) =>
      WebUrlByCategory._(parentTransaction);

  WebUrlByCategory._(super.parentTransaction);

  @override
  Future<String> internalExecute(Queue<InAppWebViewController> controllers, [Completer? onComplete]) async {
    var controller = controllers.removeFirst();

    final transaction = parentTransaction == null ? Sentry.startTransaction('WebUrlByCategory', getTaskId()) : parentTransaction!.startChild(getTaskId());
    late ISentrySpan span;

    await controller.customLoadPage(
      "https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW8030n?sap-language=KO",
      parentTransaction: transaction,
      login: true,
    );

    span = transaction.startChild("get_viewer_url");
    var url = (await controller.callAsyncJavaScript(functionBody: "return await ssurade.crawl.getGradeViewerURL().catch(() => {});"))!.value;
    span.finish(status: const SpanStatus.ok());

    transaction.finish(status: const SpanStatus.ok());

    return url;
  }

  @override
  int getTimeout() {
    return globals.setting.timeoutAllGrade;
  }

  @override
  String getTaskId() {
    return "all_grade_by_category";
  }
}
