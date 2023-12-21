import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Expando<Function(String?)> _jsAlertCallback = Expando();
Expando<Function(String)> _jsRedirectCallback = Expando();
Expando<Completer<void>> _pageLoaded = Expando();

extension WebViewControllerExtension on InAppWebViewController {
  Function(String?) get jsAlertCallback {
    return _jsAlertCallback[platform] ??= (_) {};
  }

  set jsAlertCallback(Function(String?) value) {
    _jsAlertCallback[platform] = value;
  }

  Function(String) get jsRedirectCallback {
    return _jsRedirectCallback[platform] ??= (_) {};
  }

  set jsRedirectCallback(Function(String) value) {
    _jsRedirectCallback[platform] = value;
  }

  set waitForLoadingPage(Completer<void> value) => _pageLoaded[platform] = value;

  Completer<void> get waitForLoadingPage => _pageLoaded[platform] ??= Completer();

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
}
