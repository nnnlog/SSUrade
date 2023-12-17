import 'dart:developer';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/Crawler.dart';
import 'package:ssurade/crawling/common/CrawlingTask.dart';
import 'package:ssurade/crawling/common/WebViewControllerExtension.dart';
import 'package:tuple/tuple.dart';

class EntranceGraduateYear extends CrawlingTask<Tuple2<String, String>?> {
  factory EntranceGraduateYear.get({
    ISentrySpan? parentTransaction,
  }) =>
      EntranceGraduateYear._(parentTransaction);

  EntranceGraduateYear._(ISentrySpan? parentTransaction) : super(parentTransaction);

  @override
  String task_id = "entrance_graduate_year";

  @override
  Future<Tuple2<String, String>?> internalExecute(InAppWebViewController controller) async {
    bool isFinished = false;

    final transaction = parentTransaction == null ? Sentry.startTransaction('EntranceGraduateYear', task_id) : parentTransaction!.startChild(task_id);
    late ISentrySpan span;

    late Tuple2<String, String>? result;
    try {
      result = await Future.any([
        Future(() async {
          if (!(await Crawler.loginSession(parentTransaction: transaction).directExecute(controller))) {
            return null;
          }

          await controller.customLoadPage("https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW1001n?sap-language=KO", parentTransaction: transaction);

          span = transaction.startChild("get_data");
          var data = await controller.customExecuteJavascript("ssurade.crawl.getStudentInfo();");
          result = Tuple2(data[0], data[1]);
          span.finish();

          return result;
        }),
        Future.delayed(const Duration(seconds: 10), () => null),
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
      isFinished = true;
      transaction.status = result != null ? const SpanStatus.ok() : const SpanStatus.internalError();
      transaction.finish();
    }

    return result;
  }
}
