import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ssurade/crawling/Crawler.dart';
import 'package:ssurade/crawling/WebViewControllerExtension.dart';
import 'package:ssurade/types/Progress.dart';

class BackgroundWebView extends StatefulWidget {
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
        },
        onJsAlert: (controller, action) async {
          controller.jsAlertCallback();
        },
        onJsConfirm: (controller, action) async {
          return JsConfirmResponse(); // cancel confirm event
        },
        onJsPrompt: (controller, action) async {
          return JsPromptResponse(); // cancel prompt event
        },
        onLoadStart: (InAppWebViewController controller, Uri? uri) async {
          controller.webViewXHRTotalCount = 0;
          controller.webViewXHRRunningCount = 0;

          controller.evaluateJavascript(source: """
          let XHR = XMLHttpRequest;

          var open = XHR.prototype.open;
          var send = XHR.prototype.send;

          XHR.prototype.open = function (method, url, async, user, pass) {
              this._url = url;
              open.call(this, method, url, async, user, pass);
          };

          XHR.prototype.send = function (data) {
              var self = this;
              var existReady = false;

              function onReadyStateChange() {
                  if(self.readyState === 2) {
                      existReady = true;
                      window.flutter_inappwebview.callHandler('start', self._url);
                  }
                  if(self.readyState === 4 && existReady) {
                      window.flutter_inappwebview.callHandler('end', self._url);
                  }

                  if(self._oldOnReadyStateChange) {
                      self._oldOnReadyStateChange();
                  }
              }

              if (!self._oldOnReadyStateChange) self._oldOnReadyStateChange = this.onreadystatechange;
              this.onreadystatechange = onReadyStateChange;

              send.call(this, data);
          }
          """);
        },
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(),
        ),
      ),
    );
  }
}
