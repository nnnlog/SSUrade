import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/crawling_task.dart';
import 'package:ssurade/crawling/common/webview_controller_extension.dart';
import 'package:ssurade/crawling/error/unauthenticated_exception.dart';
import 'package:ssurade/filesystem/filesystem.dart';

/// Execute task with headless webview.
class WebViewWorker {
  static List<String> webViewScript = [];
  static WebViewWorker instance = WebViewWorker._();
  static String _lightspeedCache = "";

  WebViewWorker._();

  factory WebViewWorker() => instance;

  /// run task in here. resolve value or cancel task using Completer.
  Future<Completer<T>> runTask<T>(Future<T> Function(Queue<InAppWebViewController>, [Completer? onComplete]) callback, CrawlingTask<T> taskInformation) async {
    var list = <HeadlessInAppWebView>[];
    var futures = <Future>[];
    for (int i = 0; i < taskInformation.getWebViewCount(); i++) {
      futures.add(_initWebView().then((webView) {
        list.add(webView);
      }));
    }
    await Future.wait(futures);

    var ret = Completer<T>();

    var timer = Timer(Duration(seconds: taskInformation.getTimeout()), () {
      ret.completeError(TimeoutException(taskInformation.getTaskId(), Duration(seconds: taskInformation.getTimeout())));
    });

    ret.future.catchError((error, stacktrace) {
      var reportError = true;

      if (ret.isCompleted) reportError = false;
      if (error is UnauthenticatedException) reportError = false;
      if (error is TimeoutException) reportError = false;
      if (error is MissingPluginException) reportError = false;

      if (reportError) {
        taskInformation.parentTransaction?.throwable = error;

        Sentry.captureException(
          error,
          stackTrace: stacktrace,
          withScope: (scope) {
            scope.span = taskInformation.parentTransaction;
            scope.level = SentryLevel.error;
          },
        );

        taskInformation.parentTransaction?.finish(status: const SpanStatus.internalError());
      }

      Logger().e(error, stackTrace: stacktrace);
    }).whenComplete(() async {
      if (timer.isActive) timer.cancel();

      for (var webView in list) {
        webView.webViewController!.customDispose();
        webView.platform.dispose().whenComplete(() => webView.dispose());
      }
    });

    callback(Queue()..addAll(list.map((e) => e.webViewController!)), ret).then((value) {
      if (!ret.isCompleted) {
        ret.complete(value);
      }
    }).catchError((error, stacktrace) {
      ret.completeError(error, stacktrace);
    });
    return ret;
  }

  void cancelTask(Completer completer) {
    completer.completeError(Exception("canceled by user"));
  }

  Future<HeadlessInAppWebView> _initWebView() async {
    var dir = Directory(getPath("webview_cache"));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    var ret = Completer<HeadlessInAppWebView>();
    late HeadlessInAppWebView webView;
    webView = HeadlessInAppWebView(
      onWebViewCreated: (controller) {
        controller.addJavaScriptHandler(
            handlerName: "load",
            callback: (_) {
              final waitForLoadingPage = controller.waitForLoadingPage;
              if (waitForLoadingPage != null) {
                waitForLoadingPage.complete();
                controller.waitForLoadingPage = null;
              }
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
      onLoadStop: (InAppWebViewController controller, Uri? url) async {
        await Future.wait(webViewScript.map((e) => controller.evaluateJavascript(source: e)));
      },
      shouldInterceptRequest: (InAppWebViewController controller, WebResourceRequest request) async {
        if (request.url.toString().startsWith("https://ecc.ssu.ac.kr/sap/public/bc/ur/nw7/js/lightspeed.js")) {
          if (_lightspeedCache.isEmpty) {
            // _lightspeedCache =
            //     (await http.get(Uri.parse("https://gist.githubusercontent.com/nnnlog/7f2420106e0fdf9260ee7e736c3b3c70/raw/ec02c5a98485fdd297485a585ac2b3c25f0d9bda/lightspeed.js"))).body;
            _lightspeedCache = await rootBundle.loadString("assets/js/lightspeed.js");
          }
          return WebResourceResponse(contentType: "application/x-javascript", data: Uint8List.fromList(_lightspeedCache.codeUnits));
        }
        if ((request.url.path.endsWith(".css") && !request.url.toString().contains("ecc.ssu.ac.kr")) || request.url.toString().startsWith("https://fonts.googleapis.com/css")) {
          return WebResourceResponse(contentType: "text/css", data: Uint8List.fromList([]));
        }
        if (request.url.path.endsWith(".jpg")) {
          return WebResourceResponse(contentType: "image/jpeg", data: Uint8List.fromList([]));
        }
        if (request.url.path.endsWith(".png")) {
          return WebResourceResponse(contentType: "image/png", data: Uint8List.fromList([]));
        }
        if (request.url.path.endsWith(".svg")) {
          return WebResourceResponse(contentType: "image/svg+xml", data: Uint8List.fromList([]));
        }
        if (request.url.path.endsWith(".woff2")) {
          return WebResourceResponse(contentType: "font/woff2", data: Uint8List.fromList([]));
        }
        return null;
      },
      initialSettings: InAppWebViewSettings(
        useShouldInterceptRequest: true,
        appCachePath: getPath("webview_cache"),
        cacheMode: CacheMode.LOAD_CACHE_ELSE_NETWORK,
        cacheEnabled: true,
        userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
      ),
    );
    await webView.run();
    return ret.future;
  }
}
