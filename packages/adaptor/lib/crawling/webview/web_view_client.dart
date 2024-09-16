import 'dart:async';
import 'dart:convert';
import 'dart:io' as dart show Cookie;
import 'dart:typed_data';

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:ssurade_adaptor/http_configuration.dart';
import 'package:ssurade_application/ssurade_application.dart';

class WebViewControllerEventManager {
  Future<JsAlertResponse?> Function(InAppWebViewController controller, JsAlertRequest jsAlertRequest)? onJsAlert;
  Future<JsConfirmResponse?> Function(InAppWebViewController controller, JsConfirmRequest jsConfirmRequest)? onJsConfirm;
  Future<JsPromptResponse?> Function(InAppWebViewController controller, JsPromptRequest jsPromptRequest)? onJsPrompt;
  Future<WebResourceResponse?> Function(InAppWebViewController controller, WebResourceRequest request)? shouldInterceptRequest;

  WebViewControllerEventManager._({
    this.onJsAlert,
    this.onJsConfirm,
    this.onJsPrompt,
    this.shouldInterceptRequest,
  });

  factory WebViewControllerEventManager.defaults() => WebViewControllerEventManager._(
        onJsAlert: (controller, jsAlertRequest) async {
          return JsAlertResponse(
            handledByClient: true,
          );
        },
        onJsConfirm: (controller, jsConfirmRequest) async {
          return JsConfirmResponse();
        },
        onJsPrompt: (controller, jsPromptRequest) async {
          return JsPromptResponse();
        },
        shouldInterceptRequest: (controller, request) async {
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
      );
}

class WebViewClient {
  final WebViewControllerEventManager _eventManager;
  final HeadlessInAppWebView _webView;

  final LocalStorageCredentialRetrievalPort _credentialRetrievalPort;
  final LocalStorageCredentialSavePort _credentialSavePort;
  final LightspeedRetrievalPort _lightspeedRetrievalPort;

  const WebViewClient._({
    required final WebViewControllerEventManager eventManager,
    required final HeadlessInAppWebView webView,
    required final LocalStorageCredentialRetrievalPort credentialRetrievalPort,
    required final LocalStorageCredentialSavePort credentialSavePort,
    required final LightspeedRetrievalPort lightspeedRetrievalPort,
  })  : _eventManager = eventManager,
        _webView = webView,
        _credentialRetrievalPort = credentialRetrievalPort,
        _credentialSavePort = credentialSavePort,
        _lightspeedRetrievalPort = lightspeedRetrievalPort;

  InAppWebViewController get _controller => _webView.webViewController!;

  WebViewControllerEventManager get eventManager => _eventManager;

  static List<WebUri> get _cookieDomains => [WebUri("https://.ssu.ac.kr"), WebUri("https://ecc.ssu.ac.kr")];

  Future<List<Cookie>> get cookies async {
    final controller = _controller;
    List<Cookie> cookies = [];
    for (var url in _cookieDomains) {
      cookies.addAll((await CookieManager.instance().getCookies(url: url, webViewController: controller)));
    }
    return cookies;
  }

  Future<void> loadPage(String url) async {
    final controller = _controller;

    for (var url in _cookieDomains) {
      await CookieManager.instance().deleteCookies(url: url, webViewController: controller);
    }

    await _credentialRetrievalPort.retrieveCredential().then((credential) async {
      if (credential != null) {
        final cookies = credential.cookies.map((raw) => Cookie.fromMap(raw)).whereType<Cookie>().toList();
        for (final cookie in cookies) {
          await CookieManager.instance().setCookie(url: WebUri("https://${cookie.domain}"), name: cookie.name, value: cookie.value, domain: cookie.domain, webViewController: controller);
        }
      }
    });

    final response = await http.get(Uri.parse(url), headers: {
      "Cookie": (await cookies).map((c) => c.toString()).join("; "),
      "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"
    });

    if (response.headersSplitValues["set-cookie"] != null) {
      final cookies = response.headersSplitValues["set-cookie"]!.map((e) {
        return dart.Cookie.fromSetCookieValue(e).let((cookie) {
          return Cookie(name: cookie.name, value: cookie.value, domain: cookie.domain, path: cookie.path);
        });
      }).toList();

      for (final cookie in cookies) {
        await CookieManager.instance().setCookie(url: WebUri("https://${cookie.domain}"), name: cookie.name, value: cookie.value, webViewController: controller);
      }

      _credentialRetrievalPort.retrieveCredential().then((credential) async {
        if (credential != null) {
          credential = credential.copyWith(cookies: (await cookies).map((cookie) => cookie.toMap()));
          await _credentialSavePort.saveCredential(credential);
        }
      });
    }

    var body = response.body;
    if (body.contains("lightspeed.js")) {
      final document = parse(body);
      final script = document.querySelector("script[src*='lightspeed.js']");
      if (script != null) {
        final scriptUrl = script.attributes["src"]!;
        final lightspeed = await _lightspeedRetrievalPort.retrieveLightspeed(Uri.parse(scriptUrl).query);

        script.innerHtml = "document.currentScript.src = atob(`${base64Encode(utf8.encode(scriptUrl))}`);\n";
        script.innerHtml += "eval(atob(`${base64Encode(utf8.encode(lightspeed.data))}`));";
        script.attributes.remove("src");

        body = document.outerHtml;
      }
    }

    await controller.loadData(data: body, baseUrl: WebUri(url));
  }

  Future<void> dispose() async {
    await _webView.dispose();
  }
}

@singleton
class WebViewClientGenerator {
  final LocalStorageCredentialRetrievalPort _credentialRetrievalPort;
  final LocalStorageCredentialSavePort _credentialSavePort;
  final LightspeedRetrievalPort _lightspeedRetrievalPort;

  const WebViewClientGenerator({
    required final LocalStorageCredentialRetrievalPort credentialRetrievalPort,
    required final LocalStorageCredentialSavePort credentialSavePort,
    required final LightspeedRetrievalPort lightspeedRetrievalPort,
  })  : _credentialRetrievalPort = credentialRetrievalPort,
        _credentialSavePort = credentialSavePort,
        _lightspeedRetrievalPort = lightspeedRetrievalPort;

  Future<WebViewClient> create() async {
    final ret = Completer<void>();
    final eventManager = WebViewControllerEventManager.defaults();
    final webView = HeadlessInAppWebView(
      onWebViewCreated: (controller) {
        ret.complete();
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

    return WebViewClient._(
      eventManager: eventManager,
      webView: webView,
      credentialRetrievalPort: _credentialRetrievalPort,
      credentialSavePort: _credentialSavePort,
      lightspeedRetrievalPort: _lightspeedRetrievalPort,
    );
  }
}
