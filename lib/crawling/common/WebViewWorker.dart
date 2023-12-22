import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:ssurade/crawling/common/WebViewControllerExtension.dart';
import 'package:ssurade/filesystem/FileSystem.dart';

/// Execute task with headless webview.
class WebViewWorker {
  static List<String> webViewScript = [];
  static WebViewWorker instance = WebViewWorker._();
  static String _lightspeedCache = "";

  WebViewWorker._();

  factory WebViewWorker() => instance;

  /// run task in here. resolve value or cancel task using Completer.
  Future<Completer<T>> runTask<T>(Future<T> Function(InAppWebViewController) callback) async {
    var ret = Completer<T>();
    var webView = await _initWebView();
    ret.future.whenComplete(() async {
      await webView.platform.dispose();
      await webView.dispose();
    });
    callback(webView.webViewController!).then((value) {
      if (!ret.isCompleted) {
        ret.complete(value);
      }
    });
    return ret;
  }

  void cancelTask(Completer completer) {
    completer.completeError(Error());
  }

  // TODO: so slow due to cache miss (maybe?)
  Future<HeadlessInAppWebView> _initWebView() async {
    var ret = Completer<HeadlessInAppWebView>();
    late HeadlessInAppWebView webView;
    webView = HeadlessInAppWebView(
      onWebViewCreated: (controller) {
        controller.addJavaScriptHandler(
            handlerName: "load",
            callback: (_) {
              controller.waitForLoadingPage?.complete();
            });

        ret.complete(webView);
      },
      onJsAlert: (controller, action) async {
        controller.jsAlertCallback(action.message);
        return JsAlertResponse(
          handledByClient: true,
        ); // cancel alert event
      },
      onJsConfirm: (controller, action) async {
        return JsConfirmResponse(); // cancel confirm event
      },
      onJsPrompt: (controller, action) async {
        return JsPromptResponse(); // cancel prompt event
      },
      onLoadStart: (InAppWebViewController controller, Uri? url) {
        Future.wait(webViewScript.map((e) => controller.evaluateJavascript(source: e)));
      },
      shouldInterceptRequest: (InAppWebViewController controller, WebResourceRequest request) async {
        if (request.url.toString().startsWith("https://ecc.ssu.ac.kr/sap/public/bc/ur/nw7/js/lightspeed.js")) {
          if (_lightspeedCache.isEmpty) {
            _lightspeedCache =
                (await http.get(Uri.parse("https://gist.githubusercontent.com/nnnlog/7f2420106e0fdf9260ee7e736c3b3c70/raw/4f3244069a7c576d3b6f1232d8b9e77dca3320ec/lightspeed.js"))).body;
          }
          return WebResourceResponse(contentType: "application/x-javascript", data: Uint8List.fromList(_lightspeedCache.codeUnits));
        }
      },
      initialSettings: InAppWebViewSettings(
        useShouldInterceptRequest: true,
        appCachePath: getPath("webview_cache"),
        cacheMode: CacheMode.LOAD_CACHE_ELSE_NETWORK,
        userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
      ),
    );
    await webView.run();
    return ret.future;
  }
}
