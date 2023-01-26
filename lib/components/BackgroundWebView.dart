import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ssurade/crawling/Crawler.dart';
import 'package:ssurade/crawling/WebViewControllerExtension.dart';
import 'package:ssurade/types/Progress.dart';

class BackgroundWebView extends StatefulWidget {
  static List<String> webViewScript = [];
  final Completer<void> webViewInit = Completer();

  BackgroundWebView(List<Future<void>> webViewInitialized, {super.key}) {
    webViewInitialized.add(webViewInit.future);
  }

  @override
  State<StatefulWidget> createState() => _BackgroundWebViewState();
}

class _BackgroundWebViewState extends State<BackgroundWebView> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1,
      height: 1,
      child: InAppWebView(
        onWebViewCreated: (controller) {
          widget.webViewInit.complete();

          Crawler.worker.addWebViewController(controller);

          controller.addJavaScriptHandler(
              handlerName: "start",
              callback: (data) {
                controller.webViewXHRTotalCount++;
                controller.webViewXHRRunningCount++;
                if (controller.webViewXHRProgress == XHRProgress.ready) {
                  controller.webViewXHRProgress = XHRProgress.running;
                }
                // log("XHR_START" + data.toString());
              });
          controller.addJavaScriptHandler(
              handlerName: "end",
              callback: (data) {
                controller.webViewXHRRunningCount--;
                if (controller.webViewXHRProgress == XHRProgress.running) {
                  controller.webViewXHRProgress = XHRProgress.finish;
                }
                // log("XHR_END" + data.toString());
              });
          controller.addJavaScriptHandler(
              handlerName: "redirect",
              callback: (data) {
                controller.jsRedirectCallback(data[0]);
              });
          controller.addJavaScriptHandler(
              handlerName: "debug",
              callback: (data) {
                log("XHR_DEBUG" + data.toString());
              });
          controller.jsRedirectCallback = (_) {};
          controller.jsAlertCallback = (_) {};
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
        onLoadStart: (InAppWebViewController controller, Uri? uri) async {
          for (var element in BackgroundWebView.webViewScript) {
            controller.evaluateJavascript(source: element);
          }
        },
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            /// [[extractDataFromViewer]]를 위한 UA 변경, OZ Viewer에서 Android 특정 버전 외에는 이상한 방법을 통한 다운로드를 택하고 있음
            userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36",
          ),
        ),
      ),
    );
  }
}
