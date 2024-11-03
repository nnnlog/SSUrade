import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:ssurade_application/domain/model/job/job.dart';

@pragma("vm:entry-point")
Future<void> _isolateMain(Map<String, dynamic> config) async {
  final SendPort sendPort = config["port"];
  final callback = PluginUtilities.getCallbackFromHandle(CallbackHandle.fromRawHandle(config["callback"]))!;
  final Map<String, dynamic> arguments = config["arguments"];

  var result = await callback(arguments);

  sendPort.send(result);
}

class IsolateCrawlingJob<T> extends Job<T> {
  final Completer<T> _completer = Completer();
  late FlutterIsolate _isolate;

  IsolateCrawlingJob(int timeout, FutureOr<T> Function(Map<String, dynamic> message) job, Map<String, dynamic> arguments) {
    final receivePort = ReceivePort();

    receivePort.listen((message) {
      receivePort.close();
      _isolate.kill();
      _completer.complete(message);
    });

    FlutterIsolate.spawn(
      _isolateMain,
      {
        "port": receivePort.sendPort,
        "callback": PluginUtilities.getCallbackHandle(job)!.toRawHandle(),
        "arguments": arguments,
      },
    ).then((isolate) {
      _isolate = isolate;
    });

    if (timeout > 0) {
      Future.delayed(Duration(seconds: timeout), () {
        if (!_completer.isCompleted) {
          receivePort.close();
          _isolate.kill();
          _completer.completeError(TimeoutException('IsolateCrawlingJob timed out after $timeout seconds'));
        }
      });
    }
  }

  @override
  void cancel() {
    _isolate.kill();
    _completer.completeError(Exception('IsolateCrawlingJob was cancelled'));
  }

  @override
  bool get finished => _completer.isCompleted;

  @override
  Future<T> get result => _completer.future;
}
