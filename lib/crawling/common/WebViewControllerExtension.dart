import 'dart:async';
import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Expando<Function(String?)> _jsAlertCallback = Expando();
Expando<Function(String)> _jsRedirectCallback = Expando();
Expando<Completer<void>> _pageLoaded = Expando();

extension WebViewControllerExtension on InAppWebViewController {
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

  Future<void> customLoadPage(String url, {bool clear = false, ISentrySpan? parentTransaction}) async {
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
    await loadUrl(urlRequest: URLRequest(url: WebUri(url)));
    await waitForLoadingPage.future;
    span?.finish(status: const SpanStatus.ok());

    transaction?.finish(status: const SpanStatus.ok());
  }

  Future customExecuteJavascript(String expression) async {
    var webMessageChannel = await createWebMessageChannel();
    var port1 = webMessageChannel!.port1;
    var port2 = webMessageChannel.port2;

    var ret = Completer();
    await port1.setWebMessageCallback((message) => ret.complete(message));

    await postWebMessage(message: WebMessage(data: "ssurade", ports: [port2]));
    port1.postMessage(WebMessage(data: expression));

    return jsonDecode(await ret.future)["data"];
  }
}
