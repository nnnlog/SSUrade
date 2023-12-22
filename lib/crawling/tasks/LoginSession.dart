import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:event/event.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as secureStorage;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/CrawlingTask.dart';
import 'package:ssurade/crawling/common/WebViewControllerExtension.dart';

/// U-Saint Session Manager
/// All WebView Controller share same CookieManager, so need only one instance for managing login session.
/// Provide Event
class LoginSession extends CrawlingTask<bool> {
  static final LoginSession _instance = LoginSession._("", "");

  factory LoginSession.get({
    ISentrySpan? parentTransaction,
  }) =>
      _instance..parentTransaction = parentTransaction;

  @override
  String task_id = "login";

  String _id;

  String _password;

  List<Cookie> _credentials = [];

  LoginSession._(this._id, this._password) : super(null);

  /// Singleton
  Future<LoginSession> loadFromFile() async {
    try {
      const storage = secureStorage.FlutterSecureStorage(aOptions: secureStorage.AndroidOptions(encryptedSharedPreferences: true));

      id = (await storage.read(key: "id")) ?? "";
      password = (await storage.read(key: "password")) ?? "";
    } catch (e) {
      id = password = "";
    }

    return this;
  }

  saveFile() async {
    const storage = secureStorage.FlutterSecureStorage(aOptions: secureStorage.AndroidOptions(encryptedSharedPreferences: true));

    await storage.write(key: "id", value: id);
    await storage.write(key: "password", value: password);
  }

  bool _isLogin = false;
  bool _isFail = false;

  bool get isEmpty {
    return _id.isEmpty || _password.isEmpty;
  }

  bool get isNotEmpty {
    return !isEmpty;
  }

  bool get isLogin {
    return _isLogin;
  }

  bool get isFail {
    return _isFail;
  }

  get id {
    return _id;
  }

  set id(value) {
    _id = value;
    _isLogin = false;
    _isFail = false;
  }

  get password {
    return _password;
  }

  set password(value) {
    _password = value;
    _isLogin = false;
    _isFail = false;
  }

  Event<Value<bool>> loginStatusChangeEvent = Event(); // broadcast event when login status change

  Event<Value<String>> loginFailEvent = Event(); // broadcast event when login fail

  Future<bool>? _future;

  logout() {
    id = password = "";
    loginStatusChangeEvent.broadcast(Value(_isLogin)); // false
  }

  Future<void> copyCredentials(InAppWebViewController controller) async {
    if ((await CookieManager.instance().getCookies(url: WebUri(".ssu.ac.kr"))).isEmpty) {
      for (var cookie in _credentials) {
        await CookieManager.instance().setCookie(url: WebUri(".ssu.ac.kr"), name: cookie.name, value: cookie.value);
      }
    }
  }

  @override
  Future<bool> internalExecute(InAppWebViewController controller) async {
    if (isLogin) {
      await copyCredentials(controller);
      return true;
    }
    if (_future != null) {
      var tmp = _future!;
      return Future(() async {
        final transaction = parentTransaction == null ? null : parentTransaction!.startChild("${task_id}_share");
        var res = await tmp;
        await copyCredentials(controller);
        transaction?.finish(status: res ? const SpanStatus.ok() : const SpanStatus.unauthenticated());
        return res;
      });
    }
    _isLogin = false;
    _isFail = false;
    Value<String>? cause;
    return _future = Future(() async {
      var fail = false;

      final transaction = parentTransaction == null ? Sentry.startTransaction('Login', task_id) : parentTransaction!.startChild(task_id);
      late ISentrySpan span;

      controller.jsAlertCallback = (String? reason) {
        fail = true;

        if (reason != null) {
          cause = Value(reason);
        }
      };

      bool res = false;
      try {
        res = await Future.any(
          [
            Future(() async {
              span = transaction.startChild("clear_cookie");
              var cookie = CookieManager.instance();
              await cookie.deleteAllCookies();
              span.finish(status: const SpanStatus.ok());

              await controller.customLoadPage(
                "https://smartid.ssu.ac.kr/Symtra_sso/smln.asp?apiReturnUrl=https%3A%2F%2Fsaint.ssu.ac.kr%2FwebSSO%2Fsso.jsp",
                clear: true,
                parentTransaction: transaction,
              );
              span = transaction.startChild("fill_form");
              await controller.evaluateJavascript(source: 'document.LoginInfo.userid.value = atob("${base64Encode(utf8.encode(_id))}");');
              await controller.evaluateJavascript(source: 'document.LoginInfo.pwd.value = atob("${base64Encode(utf8.encode(_password))}");');

              await controller.evaluateJavascript(source: 'document.LoginInfo.submit();');
              span.finish(status: const SpanStatus.ok());

              span = transaction.startChild("wait_redirection");
              while (!fail && !(await controller.getUrl()).toString().startsWith("https://saint.ssu.ac.kr/irj/portal")) {
                await Future.delayed(Duration.zero);
              }
              span.finish(status: fail ? const SpanStatus.cancelled() : const SpanStatus.ok());

              await controller.customLoadPage("https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW0000?sap-language=KO"); // loads any page

              _credentials = await CookieManager.instance().getCookies(url: WebUri(".ssu.ac.kr"));

              return !fail;
            }),
            Future.delayed(const Duration(seconds: 20), () {
              fail = true;
              return false;
            }),
          ],
        );
      } catch (e, stacktrace) {
        log(e.toString());

        transaction.throwable = e;
        Sentry.captureException(
          e,
          stackTrace: stacktrace,
          withScope: (scope) {
            scope.span = transaction;
            scope.level = SentryLevel.error;
          },
        );

        res = false;
      }

      controller.jsAlertCallback = (_) {};

      span = transaction.startChild("broadcast_event");
      _future = null;
      if (!res) {
        _isFail = true;
        loginFailEvent.broadcast(cause);
      }
      loginStatusChangeEvent.broadcast(Value(res));
      span.finish(status: const SpanStatus.ok());

      transaction.finish(status: res ? const SpanStatus.ok() : const SpanStatus.unauthenticated());

      return _isLogin = res;
    });
  }

  @override
  String toString() => "$runtimeType(id=$id, password=$password)";
}
