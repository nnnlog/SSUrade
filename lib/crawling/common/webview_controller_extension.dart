import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:cookie_store/cookie_store.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' hide Cookie;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/crawler.dart';
import 'package:ssurade/crawling/error/unauthenticated_exception.dart';
import 'package:ssurade/globals.dart' as globals;

Expando<Function(String?)> _jsAlertCallback = Expando();
Expando<Function(String)> _jsRedirectCallback = Expando();
Expando<Completer<void>> _pageLoaded = Expando();

extension WebViewControllerExtension on InAppWebViewController {
  Function(String?) get jsAlertCallback {
    return _jsAlertCallback[platform] ??= (_) {};
  }

  set jsAlertCallback(Function(String?) value) {
    _jsAlertCallback[platform] = value;
  }

  Function(String) get jsRedirectCallback {
    return _jsRedirectCallback[platform] ??= (_) {};
  }

  set jsRedirectCallback(Function(String) value) {
    _jsRedirectCallback[platform] = value;
  }

  set waitForLoadingPage(Completer<void>? value) => _pageLoaded[platform] = value;

  Completer<void>? get waitForLoadingPage => _pageLoaded[platform];

  Future<void> customLoadPage(String url, {bool clear = false, ISentrySpan? parentTransaction, bool login = false}) async {
    var transaction = parentTransaction?.startChild("load_page");

    if (clear) {
      var span = transaction?.startChild("clear_page");
      loadData(data: "");
      waitForLoadingPage = Completer();
      await waitForLoadingPage?.future;
      span?.finish(status: const SpanStatus.ok());
    }

    var loginSession = Crawler.loginSession();
    if (loginSession.hasCredentials) {
      await loginSession.copyCredentials(this);
    }

    var span = transaction?.startChild("load_url");
    for (var i = 0; i < 2; i++) {
      CookieStore store = CookieStore();
      for (var url in [WebUri("https://.ssu.ac.kr"), WebUri("https://ecc.ssu.ac.kr")]) {
        store.cookies.addAll((await CookieManager.instance().getCookies(url: url, webViewController: this)).map<Cookie>((e) => Cookie(e.name, e.value)));
      }
      var html = await http.get(Uri.parse(url), headers: {
        "Cookie": store.cookies.map((c) => "${c.name}=${c.value}").join("; "),
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"
      });
      store.cookies.clear();

      if (html.headers["set-cookie"] != null) {
        store.updateCookies(html.headers["set-cookie"]!, Uri.parse(url).host, Uri.parse(url).path);
        for (var cookie in store.cookies) {
          await CookieManager.instance().setCookie(url: WebUri("https://${cookie.domain}"), name: cookie.name, value: cookie.value);
        }
        await loginSession.refreshCredentials(this);
      }

      var body = html.body;
      if (body.contains("lightspeed.js")) {
        var document = parse(body);
        var script = document.querySelector("script[src*='lightspeed.js']");
        if (script != null) {
          var scriptUrl = script.attributes["src"]!;
          script.innerHtml = "document.currentScript.src = atob(`${base64Encode(utf8.encode(scriptUrl))}`);\n";
          script.innerHtml += "eval(atob(`${base64Encode(utf8.encode(await globals.lightspeedManager.get(Uri.parse(scriptUrl).query)))}`));";
          script.attributes.remove("src");

          body = document.outerHtml;
        }
      } else if (login) {
        if (i == 0) {
          loginSession.clearCredentials();
          await loginSession.saveFile();
          await loginSession.directExecute(Queue()..add(this));
          continue;
        } else {
          throw UnauthenticatedException();
        }
      }

      loadData(data: body, baseUrl: WebUri(url));
      break;
    }

    waitForLoadingPage = Completer();
    await waitForLoadingPage?.future;
    span?.finish(status: const SpanStatus.ok());

    transaction?.finish(status: const SpanStatus.ok());
  }

  void customDispose() {
    if (waitForLoadingPage?.isCompleted == false) waitForLoadingPage?.completeError(Exception("dispose"));
    jsAlertCallback(null);
    jsRedirectCallback("");
  }
}
