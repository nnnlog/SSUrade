import 'dart:async';

import 'package:ssurade_application/domain/model/job/job.dart';

class MainThreadCrawlingJob<T> extends Job<T> {
  final Completer<T> _completer = Completer();

  MainThreadCrawlingJob(int timeout, Future<T> Function() job) {
    Future.any([
      job(),
      Future.delayed(
        Duration(seconds: timeout),
        () => throw TimeoutException("MainThreadCrawlingJob timed out after $timeout seconds"),
      ),
    ]).then((value) {
      _completer.complete(value);
    }).catchError((error) {
      _completer.completeError(error);
    });
  }

  @override
  void cancel() {
    throw UnimplementedError("cancel() is not available in MainThreadCrawlingJob");
  }

  @override
  bool get finished => _completer.isCompleted;

  @override
  Future<T> get result => _completer.future;
}
