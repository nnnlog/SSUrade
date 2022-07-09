import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/Progress.dart';

backgroundWebView() => SizedBox(
      width: 1000,
      height: 300,
      child: InAppWebView(
        onWebViewCreated: (controller) {
          globals.webViewController = controller;
          globals.webViewInitialized = true;
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
        onAjaxReadyStateChange: (controller, ajax) async {
          globals.webViewXHRTotalCount++;

          if (ajax.readyState == AjaxRequestReadyState.HEADERS_RECEIVED) {
            if (globals.webViewXHRProgress == XHRProgress.ready) {
              globals.webViewXHRProgress = XHRProgress.running;
              globals.currentXHR = ajax.url.toString();

              // log("xhr register");
            }

            var curr = globals.detectedXHR[ajax.url.toString()] ?? 0;
            globals.detectedXHR[ajax.url.toString()] = ++curr;

            // log("xhr capture");
            // log(ajax.method.toString());
            // log(ajax.url.toString());

            globals.webViewXHRRunningCount++;
          }

          if (ajax.readyState == AjaxRequestReadyState.DONE) {
            if (globals.webViewXHRProgress == XHRProgress.running && ajax.url.toString() == globals.currentXHR) {
              globals.webViewXHRProgress = XHRProgress.finish;

              // log("xhr unregister");
            }

            var curr = globals.detectedXHR[ajax.url.toString()] ?? 0;
            if (curr > 0) {
              // log("xhr finish");
              // log(ajax.method.toString());
              // log(ajax.url.toString());

              globals.webViewXHRRunningCount--;
              curr--;

              if (curr > 0) {
                globals.detectedXHR[ajax.url.toString()] = curr;
              } else {
                globals.detectedXHR.remove(ajax.url.toString());
              }
            }
          }
          return null;
        },
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            useShouldInterceptAjaxRequest: true,
            cacheEnabled: false,
            clearCache: true,
          ),
        ),
      ),
    );
