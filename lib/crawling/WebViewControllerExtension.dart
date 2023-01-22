import 'dart:developer';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ssurade/types/Progress.dart';

Expando<int> _webViewXHRTotalCount = Expando(), _webViewXHRRunningCount = Expando();
Expando<XHRProgress> _webViewXHRProgress = Expando();
Expando<Function(String?)> _jsAlertCallback = Expando();

extension WebViewControllerExtension on InAppWebViewController {
  int get webViewXHRTotalCount {
    return _webViewXHRTotalCount[this] ??= 0;
  }

  set webViewXHRTotalCount(int value) {
    _webViewXHRTotalCount[this] = value;
  }

  int get webViewXHRRunningCount {
    return _webViewXHRRunningCount[this] ??= 0;
  }

  set webViewXHRRunningCount(int value) {
    _webViewXHRRunningCount[this] = value;
  }

  XHRProgress get webViewXHRProgress {
    return _webViewXHRProgress[this] ??= XHRProgress.none;
  }

  set webViewXHRProgress(XHRProgress value) {
    _webViewXHRProgress[this] = value;
  }

  Function(String?) get jsAlertCallback {
    return _jsAlertCallback[this] ??= (_) {};
  }

  set jsAlertCallback(Function(String?) value) {
    _jsAlertCallback[this] = value;
  }

  initForXHR() async {
    webViewXHRTotalCount = 0;
    webViewXHRRunningCount = 0;
    webViewXHRProgress = XHRProgress.none;
  }

  waitForXHR() async {
    bool first = true;
    bool existXHR = await Future.any([
      Future(() async {
        await Future.doWhile(() async {
          await Future.delayed(const Duration(milliseconds: 100));
          return webViewXHRTotalCount == 0;
        });
        return true;
      }),
      Future.delayed(const Duration(seconds: 5), () => false)
    ]);

    if (existXHR) {
      await Future.any([
        Future.doWhile(() async {
          await Future.delayed(const Duration(milliseconds: 10));
          return webViewXHRRunningCount > 0;
        }),
        Future.delayed(const Duration(seconds: 5))
      ]);
    } else {
      log("XHR 로딩 없음");
    }
  }

  waitForSingleXHRRequest() async {
    await Future.any([
      Future.doWhile(() async {
        // if (isFinished) return false;
        await Future.delayed(const Duration(milliseconds: 10));
        return webViewXHRProgress != XHRProgress.finish;
      }),
      Future.delayed(const Duration(seconds: 5))
    ]);
  }
}
