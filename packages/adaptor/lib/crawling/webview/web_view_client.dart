import 'dart:convert';
import 'dart:io' as dart show Cookie;
import 'dart:typed_data';

import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:ssurade_adaptor/asset/asset_loader_service.dart';
import 'package:ssurade_adaptor/http_configuration.dart';
import 'package:ssurade_adaptor/persistence/localstorage/lightspeed_retrieval_service.dart';
import 'package:ssurade_application/ssurade_application.dart';

class WebViewClientEventManager {
  Future<void> Function(InAppWebViewController controller, Uri? url)? onLoadStop;
  Future<JsAlertResponse?> Function(InAppWebViewController controller, JsAlertRequest jsAlertRequest)? onJsAlert;
  Future<JsConfirmResponse?> Function(InAppWebViewController controller, JsConfirmRequest jsConfirmRequest)? onJsConfirm;
  Future<JsPromptResponse?> Function(InAppWebViewController controller, JsPromptRequest jsPromptRequest)? onJsPrompt;
  Future<WebResourceResponse?> Function(InAppWebViewController controller, WebResourceRequest request)? shouldInterceptRequest;

  WebViewClientEventManager({
    this.onLoadStop,
    this.onJsAlert,
    this.onJsConfirm,
    this.onJsPrompt,
    this.shouldInterceptRequest,
  });

  factory WebViewClientEventManager.defaults() => WebViewClientEventManager(
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
  static List<WebUri> get _cookieDomains => [WebUri("https://.ssu.ac.kr"), WebUri("https://ecc.ssu.ac.kr")];
  static String get _injectorAssetPath => "js/common.js";

  final WebViewClientEventManager _eventManager;
  final HeadlessInAppWebView _webView;

  final LocalStorageCredentialPort _localStorageCredentialPort; // Replace it to internal logic of adaptor
  final LightspeedRetrievalService _lightspeedRetrievalService;
  final AssetLoaderService _assetLoaderService;

  const WebViewClient({
    required final WebViewClientEventManager eventManager,
    required final HeadlessInAppWebView webView,
    required final LocalStorageCredentialPort localStorageCredentialPort,
    required final LightspeedRetrievalService lightspeedRetrievalService,
    required final AssetLoaderService assetLoaderService,
  })  : _eventManager = eventManager,
        _webView = webView,
        _localStorageCredentialPort = localStorageCredentialPort,
        _lightspeedRetrievalService = lightspeedRetrievalService,
        _assetLoaderService = assetLoaderService;

  InAppWebViewController get _controller => _webView.webViewController!;

  WebViewClientEventManager get eventManager => _eventManager;

  Future<List<Cookie>> get cookies async {
    final controller = _controller;
    List<Cookie> cookies = [];
    for (var url in _cookieDomains) {
      cookies.addAll((await CookieManager.instance().getCookies(url: url, webViewController: controller)));
    }
    return cookies;
  }

  Future<String> get url => _controller.getUrl().then((url) => url.toString());

  Future<void> loadPage(String url) async {
    final controller = _controller;

    // load cookie from credential
    await run(() async {
      for (var url in _cookieDomains) {
        await CookieManager.instance().deleteCookies(url: url, webViewController: controller);
      }

      await _localStorageCredentialPort.retrieveCredential().then((credential) async {
        if (credential != null) {
          final cookies = credential.cookies.map((raw) => Cookie.fromMap(raw)).whereType<Cookie>().toList();
          for (final cookie in cookies) {
            await CookieManager.instance().setCookie(url: WebUri("https://${cookie.domain}"), name: cookie.name, value: cookie.value, domain: cookie.domain, webViewController: controller);
          }
        }
      });
    });

    final response = await http.get(Uri.parse(url), headers: {
      "Cookie": (await cookies).map((c) => c.toString()).join("; "),
      "User-Agent": HttpConfiguration.userAgent,
    });

    await response.headersSplitValues["set-cookie"]?.let((it) async {
      final cookies = it.map((e) {
        return dart.Cookie.fromSetCookieValue(e).let((cookie) {
          return Cookie(name: cookie.name, value: cookie.value, domain: cookie.domain, path: cookie.path);
        });
      }).toList();

      for (final cookie in cookies) {
        await CookieManager.instance().setCookie(url: WebUri("https://${cookie.domain}"), name: cookie.name, value: cookie.value, webViewController: controller);
      }

      _localStorageCredentialPort.retrieveCredential().then((credential) async {
        if (credential != null) {
          credential = credential.copyWith(cookies: (await cookies).map((cookie) => cookie.toMap()).toList());
          await _localStorageCredentialPort.saveCredential(credential);
        }
      });
    });

    var body = response.body;
    if (body.contains("lightspeed.js")) {
      final document = parse(body);
      final script = document.querySelector("script[src*='lightspeed.js']");
      if (script != null) {
        final scriptUrl = script.attributes["src"]!;
        final lightspeed = await _lightspeedRetrievalService.retrieveLightspeed(Uri.parse(scriptUrl).query);

        script.innerHtml = "document.currentScript.src = atob(`${base64Encode(utf8.encode(scriptUrl))}`);\n";
        script.innerHtml += "eval(atob(`${base64Encode(utf8.encode(lightspeed.data))}`));";
        script.attributes.remove("src");

        body = document.outerHtml;
      }
    }

    eventManager.onLoadStop = (controller, _) async {
      await _controller.evaluateJavascript(source: await _assetLoaderService.loadAsset(_injectorAssetPath));
    };

    await controller.loadData(data: body, baseUrl: WebUri(url));
  }

  Future<dynamic> execute(String javascript) async {
    return _controller.callAsyncJavaScript(functionBody: javascript).then((value) => value?.value);
  }

  Future<void> dispose() async {
    await _webView.dispose();
  }
}
