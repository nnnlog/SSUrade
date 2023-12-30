import 'dart:async';
import 'dart:collection';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/Crawler.dart';

abstract class CrawlingTask<T> {
  // abstract static method : get(...), return new instance or existed instance with args.
  ISentrySpan? parentTransaction;

  CrawlingTask(this.parentTransaction);

  /// @protected
  Future<T> internalExecute(Queue<InAppWebViewController> controllers, [Completer? onComplete]);

  /// @public
  Future<T> directExecute(Queue<InAppWebViewController> controllers) => internalExecute(controllers);

  /// Execute new task in here. It'll create new [InAppWebViewController] and holds itself timer for timeout.
  /// If timeouts, throw [TimeoutException].
  Future<T> execute() async {
    var completer = await Crawler.worker.runTask(internalExecute, this);
    return completer.future;
  }

  int getTimeout();

  int getWebViewCount() {
    return 1;
  }

  String getTaskId();
}
