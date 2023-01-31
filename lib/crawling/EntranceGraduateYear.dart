import 'dart:developer';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/Crawler.dart';
import 'package:ssurade/crawling/CrawlingTask.dart';
import 'package:ssurade/crawling/WebViewControllerExtension.dart';
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
          if (isFinished) return null;
          if (!(await Crawler.loginSession(parentTransaction: transaction).directExecute(controller))) {
            return null;
          }

          await controller.customLoadPage("https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW1001n?sap-language=KO", parentTransaction: transaction);

          span = transaction.startChild("get_data");
          try {
            String? entrance = await controller.evaluateJavascript(
                source:
                    'document.querySelectorAll("table tr div div:nth-child(1) span span:nth-child(2) tbody:nth-child(2) tr td span span table tbody tr:nth-child(1) td:nth-child(1) table tr table tr:nth-child(1) td:nth-child(2) span input")[0].value;');
            if (entrance == null) throw Exception("Entrance year is null");

            String? graduate = await controller.evaluateJavascript(
                source:
                    'document.querySelectorAll("table tbody tr div div:nth-child(1) span span:nth-child(2) table tbody:nth-child(2) tr span span table tr:nth-child(1) td:nth-child(1) table tr table tr:nth-child(18) td:nth-child(2) span input")[0].value;');
            if (graduate == null) throw Exception("Graduate year is null");

            result = Tuple2(entrance, graduate);
          } catch (e, stacktrace) {
            span.throwable = e;
            Sentry.captureException(
              e,
              stackTrace: stacktrace,
              withScope: (scope) {
                scope.span = span;
                scope.level = SentryLevel.error;
              },
            );
            span.finish(status: const SpanStatus.internalError());

            log(e.toString());
            log(stacktrace.toString());

            return result = null;
          }
          if (!span.finished) {
            span.finish(status: const SpanStatus.ok());
          }

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
