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
            } else if (globals.webViewXHRProgress != XHRProgress.none) {
              log("ajax error 1");
            }

            globals.webViewXHRRunningCount++;
          }

          if (ajax.readyState == AjaxRequestReadyState.DONE) {
            if (globals.webViewXHRProgress == XHRProgress.running) {
              globals.webViewXHRProgress = XHRProgress.finish;
            }

            globals.webViewXHRRunningCount--;
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
