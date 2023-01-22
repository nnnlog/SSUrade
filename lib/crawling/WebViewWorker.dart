import 'dart:async';
import 'dart:collection';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tuple/tuple.dart';

/// Execute only one task in one [InAppWebViewController] at time. (support parallel tasks)
class WebViewWorker {
  static WebViewWorker instance = WebViewWorker._();

  WebViewWorker._();

  factory WebViewWorker() => instance;

  final Queue<InAppWebViewController> _controllers = Queue();
  final Queue<Tuple2<Completer, Future Function(InAppWebViewController)>> _queue = Queue();

  void addWebViewController(InAppWebViewController controller) {
    _controllers.add(controller);
    _run();
  }

  /// add task in here. resolving value or canceling task uses Completer (return value)
  Completer<T> addTask<T>(Future<T> Function(InAppWebViewController) callback) {
    var ret = Completer<T>();
    _queue.add(Tuple2(ret, callback));
    _run();
    return ret;
  }

  /// TODO: already running task doesn't affect.
  void cancelTask(Completer completer) {
    completer.completeError(Error());
  }

  /// work synchronously
  void _run() {
    if (_queue.isEmpty || _controllers.isEmpty) return;

    var task = _queue.removeFirst();
    if (task.item1.isCompleted) return _run(); // cancelled task, find next task.

    var controller = _controllers.removeFirst();

    task.item2(controller).then((ret) {
      if (!task.item1.isCompleted) {
        task.item1.complete(ret);
      }
      _controllers.add(controller);
      _run();
    });
  }
}
