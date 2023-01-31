import 'dart:async';
import 'dart:developer';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/Progress.dart';

Expando<int> _webViewXHRTotalCount = Expando(), _webViewXHRRunningCount = Expando();
Expando<XHRProgress> _webViewXHRProgress = Expando();
Expando<Function(String?)> _jsAlertCallback = Expando();
Expando<Function(String)> _jsRedirectCallback = Expando();
Expando<Completer<void>> _pageLoaded = Expando();

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

  Function(String) get jsRedirectCallback {
    return _jsRedirectCallback[this] ??= (_) {};
  }

  set jsRedirectCallback(Function(String) value) {
    _jsRedirectCallback[this] = value;
  }

  set waitForLoadingPage(Completer<void> value) => _pageLoaded[this] = value;

  Completer<void> get waitForLoadingPage => _pageLoaded[this] ??= Completer();

  Future<void> customLoadPage(String url, {bool xhr = true, bool clear = false, ISentrySpan? parentTransaction}) async {
    var transaction = parentTransaction?.startChild("load_page");
    if (clear) {
      var span = transaction?.startChild("clear_page");
      waitForLoadingPage = Completer();
      await loadData(data: "");
      await waitForLoadingPage.future;
      span?.finish(status: const SpanStatus.ok());
    }

    var span = transaction?.startChild("load_url");
    waitForLoadingPage = Completer();
    initForXHR();
    await loadUrl(urlRequest: URLRequest(url: Uri.parse(url)));
    span?.finish(status: const SpanStatus.ok());

    span = transaction?.startChild("wait_xhr_and_page");
    await Future.wait([
      xhr ? waitForXHR(parentTransaction: span) : Future(() => null),
      waitForLoadingPage.future,
    ]);
    span?.finish(); // set status in waitForXHR()

    transaction?.finish(status: const SpanStatus.ok());
  }

  void initForXHR() {
    webViewXHRTotalCount = 0;
    webViewXHRRunningCount = 0;
    webViewXHRProgress = XHRProgress.none;
  }

  Future<void> waitForXHR({ISentrySpan? parentTransaction}) async {
    var span = parentTransaction?.startChild("exist_xhr");
    bool existXHR = await Future.any([
      Future(() async {
        await Future.doWhile(() async {
          await Future.delayed(const Duration(milliseconds: 1));
          return webViewXHRTotalCount == 0;
        });
        return true;
      }),
      Future.delayed(const Duration(seconds: 5), () => false)
    ]);
    span?.finish(status: existXHR ? const SpanStatus.ok() : const SpanStatus.cancelled());

    if (existXHR) {
      var span = parentTransaction?.startChild("wait_xhr");
      await Future.any([
        Future.doWhile(() async {
          await Future.delayed(const Duration(milliseconds: 1));
          return webViewXHRRunningCount > 0;
        }),
        Future.delayed(const Duration(seconds: 5))
      ]);
      span?.finish(status: const SpanStatus.ok());

      parentTransaction?.status = const SpanStatus.ok();
    } else {
      log("XHR 로딩 없음");
      parentTransaction?.throwable = Exception("No XHR Loading");
      parentTransaction?.status = const SpanStatus.cancelled();

      globals.analytics.logEvent(name: "xhr_loading_no");
    }
  }

  waitForSingleXHRRequest() async {
    await Future.any([
      Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 1));
        return webViewXHRProgress != XHRProgress.finish;
      }),
      Future.delayed(const Duration(seconds: 5))
    ]);
  }
}
