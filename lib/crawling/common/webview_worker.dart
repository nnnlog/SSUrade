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
  static List<String> webViewScriptOnStart = [];
  static List<String> webViewScriptOnStop = [];
  static WebViewWorker instance = WebViewWorker._();

  WebViewWorker._();

  factory WebViewWorker() => instance;

  /// run task in here. resolve value or cancel task using Completer.
  Future<Completer<T>> runTask<T>(Future<T> Function(Queue<InAppWebViewController>, [Completer? onComplete]) callback, CrawlingTask<T> taskInformation) async {
    var list = <HeadlessInAppWebView>[];
    var futures = <Future>[];
    for (int i = 0; i < taskInformation.getWebViewCount(); i++) {
      futures.add(initWebView().then((webView) {
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

  Future<HeadlessInAppWebView> initWebView() async {
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
      onLoadStart: (InAppWebViewController controller, WebUri? url) async {
        await Future.wait(webViewScriptOnStart.map((e) => controller.evaluateJavascript(source: e)));
      },
      onLoadStop: (InAppWebViewController controller, Uri? url) async {
        await Future.wait(webViewScriptOnStop.map((e) => controller.evaluateJavascript(source: e)));
      },
      shouldInterceptRequest: (InAppWebViewController controller, WebResourceRequest request) async {
        // works for android only ->  replace to customLoadPage
        // if (request.url.toString().startsWith("https://ecc.ssu.ac.kr/sap/public/bc/ur/nw7/js/lightspeed.js")) {
        //   return WebResourceResponse(contentType: "application/x-javascript", data: Uint8List.fromList((await globals.lightspeedManager.get(request.url.query)).codeUnits));
        // }
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
        isInspectable: true,
        userAgent: Platform.isIOS
            ? "Mozilla/5.0 (iPhone; CPU iPhone OS 17_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1"
            : "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.6668.81 Mobile Safari/537.36",
      ),
    );
    await webView.run();
    return ret.future;
  }
}
