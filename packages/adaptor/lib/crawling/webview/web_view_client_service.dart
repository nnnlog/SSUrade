import 'dart:async';

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:injectable/injectable.dart';
import 'package:ssurade_adaptor/asset/asset_loader_service.dart';
import 'package:ssurade_adaptor/crawling/cache/credential_manager_service.dart';
import 'package:ssurade_adaptor/crawling/webview/web_view_client.dart';
import 'package:ssurade_adaptor/http_configuration.dart';
import 'package:ssurade_adaptor/persistence/localstorage/lightspeed_retrieval_service.dart';

@singleton
class WebViewClientService {
  final CredentialManagerService _credentialCacheService;
  final LightspeedRetrievalService _lightspeedRetrievalService;
  final AssetLoaderService _assetLoaderService;

  const WebViewClientService({
    required CredentialManagerService credentialCacheService,
    required LightspeedRetrievalService lightspeedRetrievalService,
    required AssetLoaderService assetLoaderService,
  })  : _credentialCacheService = credentialCacheService,
        _lightspeedRetrievalService = lightspeedRetrievalService,
        _assetLoaderService = assetLoaderService;

  Future<WebViewClient> create() async {
    final ret = Completer<void>();
    final eventManager = WebViewClientEventManager.defaults();
    final webView = HeadlessInAppWebView(
      onWebViewCreated: (controller) {
        ret.complete();
      },
      onLoadStop: (controller, url) async {
        return eventManager.onLoadStop?.let((it) => it(controller, url));
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
      credentialCacheService: _credentialCacheService,
      lightspeedRetrievalService: _lightspeedRetrievalService,
      assetLoaderService: _assetLoaderService,
    );
  }
}
