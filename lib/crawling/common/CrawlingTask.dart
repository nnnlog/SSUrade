import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/Crawler.dart';

abstract class CrawlingTask<T> {
  // abstract static method : get(...), return new instance or existed instance with args.
  late String task_id; // analytics task_id
  ISentrySpan? parentTransaction;

  CrawlingTask(this.parentTransaction);

  Future<T> internalExecute(InAppWebViewController controller);

  Future<T> directExecute(InAppWebViewController controller) => internalExecute(controller);

  Future<T> execute() async {
    return (await Crawler.worker.runTask(directExecute)).future;
  }
}
