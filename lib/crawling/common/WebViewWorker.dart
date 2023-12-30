import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/CrawlingTask.dart';
import 'package:ssurade/crawling/common/WebViewControllerExtension.dart';
import 'package:ssurade/crawling/error/UnauthenticatedExcpetion.dart';
import 'package:ssurade/filesystem/FileSystem.dart';

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
