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

Future<DataFrame?> extractDataFromViewer(InAppWebViewController controller) async {
  if (!(await controller.getUrl()).toString().startsWith("https://office.ssu.ac.kr/")) return null;
  DataFrame ret = DataFrame();
  try {
    if (await controller.evaluateJavascript(source: """document.querySelector("input[tabindex='4']")""") == null) return null;

    await controller.evaluateJavascript(source: """document.querySelector("input[tabindex='4']").click()""");

    while (await controller.evaluateJavascript(source: """document.querySelectorAll("select").length""") < 3) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
    await controller.evaluateJavascript(source: """document.querySelectorAll("select")[1].selectedIndex = 6""");
    await controller.evaluateJavascript(source: """document.querySelectorAll("select")[1].dispatchEvent(new Event('change'))""");
    await controller
        .evaluateJavascript(source: """document.querySelectorAll("select")[1].closest("tr").querySelector("input").value = '$SEPARATOR'""");

    await controller.evaluateJavascript(source: """document.querySelectorAll("select")[2].selectedIndex = 1""");
    await controller.evaluateJavascript(source: """document.querySelectorAll("select")[2].dispatchEvent(new Event('change'))""");

    Completer<String> download = Completer();
    controller.addJavaScriptHandler(
        handlerName: "download",
        callback: (data) {
          download.complete(data[0] as String);
        });

    await controller.evaluateJavascript(source: """document.querySelector("button[classname='confirmButtonClass']").click()""");

    var rawText = await Future.any([
      download.future,
      Future.delayed(const Duration(seconds: 3)).then((value) => "fail"),
    ]);

    await controller.evaluateJavascript(source: """document.querySelector("button[classname='confirmButtonClass']").click()""");

    controller.removeJavaScriptHandler(handlerName: "download");

    ret = _parse(rawText)[0];
  } catch (error, stackTrace) {
    log(error.toString());
    log(stackTrace.toString());

    Sentry.captureException(
      error,
      stackTrace: stackTrace,
    );
  }
  return ret;
}
