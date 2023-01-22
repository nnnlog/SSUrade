import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ssurade/crawling/Crawler.dart';

abstract class CrawlingTask<T> {
  // abstract static method : get(...), return new instance or existed instance with args.

  Future<T> directExecute(InAppWebViewController controller);

  Future<T> execute() => Crawler.worker.addTask(directExecute).future;
}
