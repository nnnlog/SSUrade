import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/Progress.dart';

backgroundWebView() => SizedBox(
      width: 1,
      height: 1,
      child: InAppWebView(
        onWebViewCreated: (controller) {
          globals.webViewController = controller;
          globals.webViewInitialized = true;

          controller.addJavaScriptHandler(
              handlerName: "start",
              callback: (data) {
                globals.webViewXHRTotalCount++;
                globals.webViewXHRRunningCount++;
                if (globals.webViewXHRProgress == XHRProgress.ready) {
                  globals.webViewXHRProgress = XHRProgress.running;
                }
                // log("XHR_START" + data.toString());
              });
          controller.addJavaScriptHandler(
              handlerName: "end",
              callback: (data) {
                globals.webViewXHRRunningCount--;
                if (globals.webViewXHRProgress == XHRProgress.running) {
                  globals.webViewXHRProgress = XHRProgress.finish;
                }
                // log("XHR_END" + data.toString());
              });
        },
        onJsAlert: (controller, action) async {
          globals.jsAlertCallback();
        },
        onJsConfirm: (controller, action) async {
          return JsConfirmResponse(); // cancel confirm event
        },
        onJsPrompt: (controller, action) async {
          return JsPromptResponse(); // cancel prompt event
        },
        onLoadStart: (InAppWebViewController controller, Uri? uri) async {
          globals.webViewXHRTotalCount = 0;
          globals.webViewXHRRunningCount = 0;
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
