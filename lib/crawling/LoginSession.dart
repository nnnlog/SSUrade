import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:event/event.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/CrawlingTask.dart';
import 'package:ssurade/crawling/WebViewControllerExtension.dart';

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

  LoginSession._(this._id, this._password) : super(null);

  /// Singleton
  Future loadFromFile() async {
    const storage = FlutterSecureStorage();

    id = (await storage.read(key: "id")) ?? "";
    password = (await storage.read(key: "password")) ?? "";
  }

  saveFile() async {
    const storage = FlutterSecureStorage();

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

  @override
  Future<bool> internalExecute(InAppWebViewController controller) async {
    if (isLogin) return true;
    if (_future != null) {
      return Future(() async {
        final transaction = parentTransaction == null ? null : parentTransaction!.startChild("${task_id}_share");
        var res = await _future!;
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
                xhr: false,
                clear: true,
                parentTransaction: transaction,
              );

              span = transaction.startChild("fill_form");
              await controller.evaluateJavascript(source: 'document.LoginInfo.userid.value = atob("${base64Encode(utf8.encode(_id))}");');
              await controller.evaluateJavascript(source: 'document.LoginInfo.pwd.value = atob("${base64Encode(utf8.encode(_password))}");');

              await controller.evaluateJavascript(source: 'document.LoginInfo.submit();');
              span.finish(status: const SpanStatus.ok());

              span = transaction.startChild("wait_redirection");
              while (!fail && (await controller.getUrl()).toString().startsWith("https://smartid.ssu.ac.kr/")) {
                await Future.delayed(const Duration(milliseconds: 10));
              }
              span.finish(status: fail ? const SpanStatus.cancelled() : const SpanStatus.ok());

              return !fail;
            }),
            Future.delayed(const Duration(seconds: 10), () {
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
