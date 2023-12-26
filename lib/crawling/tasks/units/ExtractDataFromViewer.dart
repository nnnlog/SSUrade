import 'dart:async';
import 'dart:collection';

import 'package:df/df.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/CrawlingTask.dart';
import 'package:ssurade/crawling/common/WebViewControllerExtension.dart';

class ExtractDataFromViewer extends CrawlingTask<DataFrame> {
  String uri;

  factory ExtractDataFromViewer.get(
    String uri, {
    ISentrySpan? parentTransaction,
  }) =>
      ExtractDataFromViewer._(uri, parentTransaction);

  ExtractDataFromViewer._(this.uri, ISentrySpan? parentTransaction) : super(parentTransaction);

  final String SEPARATOR = "|||||";

  List<DataFrame> _parse(String raw) {
    List<DataFrame> ret = [];

    var list = raw.split("\n").map((e) => e.split(SEPARATOR).map((e) => e.trim()).toList()).toList(); // 값에 \n이 없다고 가정함. (강의 계획서에는 \n이 있어서 이 방법으로 불가능)
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

  @override
  Future<DataFrame> internalExecute(Queue<InAppWebViewController> controllers) async {
    var controller = controllers.removeFirst();

    var transaction = parentTransaction?.startChild("extract_data_from_viewer");
    late ISentrySpan? span;
    DataFrame ret = DataFrame();

    await controller.customLoadPage(
      uri,
      parentTransaction: transaction,
    );

    span = transaction?.startChild("click_export_btn");
    var rawText = (await controller.callAsyncJavaScript(functionBody: "return await ssurade.crawl.getGradeFromViewer();"))!.value;
    span?.finish();

    span = transaction?.startChild("parse");
    ret = _parse(rawText)[0];
    span?.finish(status: const SpanStatus.ok());

    transaction?.finish(status: const SpanStatus.ok());

    return ret;
  }

  @override
  int getTimeout() {
    return 10;
  }

  @override
  String getTaskId() {
    return "extract_data_from_viewer";
  }
}
