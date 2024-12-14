import 'dart:async';
import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:injectable/injectable.dart';
import 'package:mutex/mutex.dart';
import 'package:ssurade_adaptor/crawling/webview/web_view_client.dart';
import 'package:ssurade_application/ssurade_application.dart';

@singleton
class CredentialRetrievalService {
  final Mutex _mutex = Mutex();

  Future<List<Map<String, dynamic>>?> getCookiesFromCredential(WebViewClient client, Credential credential) {
    return _mutex.protect(() async {
      {
        await client.clearCookie();

        await client.loadPage(
          "https://smartid.ssu.ac.kr/Symtra_sso/smln.asp?apiReturnUrl=https%3A%2F%2Fsaint.ssu.ac.kr%2FwebSSO%2Fsso.jsp",
          useAutoLogin: false,
        );

        Completer<String> completer = Completer();
        client.eventManager.onJsAlert = (_, message) async {
          completer.complete(message.message ?? "");
          return JsAlertResponse(handledByClient: true);
        };

        await client.directExecute('document.LoginInfo.userid.value = atob("${base64Encode(utf8.encode(credential.id))}");');
        await client.directExecute('document.LoginInfo.pwd.value = atob("${base64Encode(utf8.encode(credential.password))}");');
        await client.directExecute('document.LoginInfo.submit();');

        var res = await Future.any([
          (() async {
            while (!(await client.url).startsWith("https://saint.ssu.ac.kr/irj/portal")) {
              await Future.delayed(const Duration(milliseconds: 5));
            }
            return true;
          })(),
          completer.future,
        ]);

        if (res is String) {
          throw UnauthenticatedException(res);
        }

        client.eventManager.onJsAlert = null;
      }

      {
        await client.loadPage(
          "https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW1001n?sap-language=KO",
          useAutoLogin: false,
        );
        await client.execute("return await ssurade.lightspeed.waitForPageLoad();");
      }

      final result = await client.cookies.then((cookies) => cookies.map((cookie) => cookie.toJson()).toList());

      return result;
    });
  }
}
