import 'dart:developer';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/Crawler.dart';
import 'package:ssurade/globals.dart' as globals;

abstract class CrawlingTask<T> {
  // abstract static method : get(...), return new instance or existed instance with args.
  late String task_id; // analytics task_id
  ISentrySpan? parentTransaction;

  CrawlingTask(this.parentTransaction);

  Future<T> internalExecute(InAppWebViewController controller);

  Future<T> directExecute(InAppWebViewController controller) async {
    var start = DateTime.now();
    var res = await internalExecute(controller);
    var end = DateTime.now();

    globals.analytics.logEvent(name: "task", parameters: {
      "task_id": task_id,
      "success": (T is bool ? res : res != null).toString(),
      "duration": end.millisecondsSinceEpoch - start.millisecondsSinceEpoch,
    });
    log("${task_id} : ${end.millisecondsSinceEpoch - start.millisecondsSinceEpoch}");
    return res;
  }

  Future<T> execute() async {
    return (await Crawler.worker.runTask(directExecute)).future;
  }
}
