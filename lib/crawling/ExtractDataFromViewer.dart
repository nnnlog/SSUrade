import 'dart:async';
import 'dart:developer';

import 'package:df/df.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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
    while (await controller.evaluateJavascript(source: """document.querySelector("input[tabindex='4']")""") == null) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    span = transaction?.startChild("click_export_btn");
    await controller.evaluateJavascript(source: """document.querySelector("input[tabindex='4']").click()""");
    while (await controller.evaluateJavascript(source: """document.querySelectorAll("select").length""") < 3) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
    span?.finish(status: const SpanStatus.ok());

    span = transaction?.startChild("change_export_setting");
    await controller.evaluateJavascript(source: """document.querySelectorAll("select")[1].selectedIndex = 6""");
    await controller.evaluateJavascript(source: """document.querySelectorAll("select")[1].dispatchEvent(new Event('change'))""");
    await controller
        .evaluateJavascript(source: """document.querySelectorAll("select")[1].closest("tr").querySelector("input").value = '$SEPARATOR'""");

    await controller.evaluateJavascript(source: """document.querySelectorAll("select")[2].selectedIndex = 1""");
    await controller.evaluateJavascript(source: """document.querySelectorAll("select")[2].dispatchEvent(new Event('change'))""");
    span?.finish(status: const SpanStatus.ok());

    Completer<String> download = Completer();
    controller.addJavaScriptHandler(
        handlerName: "download",
        callback: (data) {
          download.complete(data[0] as String);
        });

    span = transaction?.startChild("download");
    await controller.evaluateJavascript(source: """document.querySelector("button[classname='confirmButtonClass']").click()""");

    var rawText = await Future.any([
      download.future,
      Future.delayed(const Duration(seconds: 3)).then((value) => "fail"),
    ]);
    span?.finish(status: rawText != "fail" ? const SpanStatus.ok() : const SpanStatus.aborted());

    span = transaction?.startChild("close_export_btn");
    await controller.evaluateJavascript(source: """document.querySelector("button[classname='confirmButtonClass']").click()""");
    span?.finish(status: const SpanStatus.ok());

    controller.removeJavaScriptHandler(handlerName: "download");

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
