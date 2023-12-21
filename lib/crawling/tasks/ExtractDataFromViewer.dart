import 'dart:async';
import 'dart:developer';

import 'package:df/df.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/WebViewControllerExtension.dart';

const String SEPARATOR = "|||||";

List<DataFrame> _parse(String raw) {
  List<DataFrame> ret = [];

  var list = raw.split("\n").map((e) => e.split(SEPARATOR).map((e) => e.trim()).toList()).toList(); // 값에 \n이 없다고 가정하면, (강의 계획서에는 \n이 있어서 이 방법으로 불가능)
  int keyPrev = -1;
  DataFrame df = DataFrame();
  for (var value in list) {
    if (keyPrev != value.length) {
      if (df.length > 0) {
        ret.add(df);
        df = DataFrame();
      }
      keyPrev = value.length;
      df.setColumns(value.map((e) => DataFrameColumn(name: e, type: String)).toList());
    } else {
      df.addRecords(value);
    }
  }
  if (df.length > 0) {
    ret.add(df);
  }
  return ret;
}

Future<DataFrame> extractDataFromViewer(InAppWebViewController controller, {ISentrySpan? parentTransaction}) async {
  if (!(await controller.getUrl()).toString().startsWith("https://office.ssu.ac.kr/")) throw Exception("webview is not viewer, current url is ${(await controller.getUrl()).toString()}");
  var transaction = parentTransaction?.startChild("get_data_from_viewer");
  late ISentrySpan? span;
  DataFrame ret = DataFrame();
  try {
    span = transaction?.startChild("click_export_btn");
    var rawText = (await controller.callAsyncJavaScript(functionBody: "return await ssurade.crawl.getGradeFromViewer();"))!.value;
    span?.finish();

    span = transaction?.startChild("parse");
    ret = _parse(rawText)[0];
    span?.finish(status: const SpanStatus.ok());
  } catch (error, stackTrace) {
    log(error.toString());
    log(stackTrace.toString());

    transaction?.throwable = error;
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.span = transaction;
        scope.level = SentryLevel.error;
      },
    );

    transaction?.finish(status: const SpanStatus.internalError());
  }
  if (transaction?.finished == false) {
    transaction?.finish(status: const SpanStatus.ok());
  }
  return ret;
}
