import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ssurade/crawling/Crawler.dart';
import 'package:ssurade/globals.dart' as globals;

abstract class CrawlingTask<T> {
  // abstract static method : get(...), return new instance or existed instance with args.
  late String task_id; // analytics task_id

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
    return res;
  }

  Future<T> execute() => Crawler.worker.addTask(directExecute).future;
}
