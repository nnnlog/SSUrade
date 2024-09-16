import 'dart:async';

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_adaptor/crawling/webview/web_view_client.dart';
import 'package:ssurade_adaptor/http_configuration.dart';
import 'package:ssurade_application/ssurade_application.dart';

@singleton
class WebViewClientService {
  final LocalStorageCredentialRetrievalPort _credentialRetrievalPort;
  final LocalStorageCredentialSavePort _credentialSavePort;
  final LightspeedRetrievalPort _lightspeedRetrievalPort;

  const WebViewClientService({
    required final LocalStorageCredentialRetrievalPort credentialRetrievalPort,
    required final LocalStorageCredentialSavePort credentialSavePort,
    required final LightspeedRetrievalPort lightspeedRetrievalPort,
  })  : _credentialRetrievalPort = credentialRetrievalPort,
        _credentialSavePort = credentialSavePort,
        _lightspeedRetrievalPort = lightspeedRetrievalPort;

  Future<WebViewClient> create() async {
    final ret = Completer<void>();
    final eventManager = WebViewClientEventManager.defaults();
    final webView = HeadlessInAppWebView(
      onWebViewCreated: (controller) {
        ret.complete();
      },
      onJsAlert: (controller, action) async {
        return eventManager.onJsAlert?.let((it) => it(controller, action));
      },
      onJsConfirm: (controller, action) async {
        return eventManager.onJsConfirm?.let((it) => it(controller, action));
      },
      onJsPrompt: (controller, action) async {
        return eventManager.onJsPrompt?.let((it) => it(controller, action));
      },
      shouldInterceptRequest: (InAppWebViewController controller, WebResourceRequest request) async {
        return eventManager.shouldInterceptRequest?.let((it) => it(controller, request));
      },
      initialSettings: InAppWebViewSettings(
        incognito: true,
        isInspectable: true,
        useShouldInterceptRequest: true,
        cacheEnabled: true,
        userAgent: HttpConfiguration.userAgent,
      ),
    );

    webView.run();

    await ret.future;

    return WebViewClient(
      eventManager: eventManager,
      webView: webView,
      credentialRetrievalPort: _credentialRetrievalPort,
      credentialSavePort: _credentialSavePort,
      lightspeedRetrievalPort: _lightspeedRetrievalPort,
    );
  }
}
