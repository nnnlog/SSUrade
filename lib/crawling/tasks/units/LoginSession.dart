import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:event/event.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as secureStorage;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/background/BackgroundService.dart';
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

  bool isBackground = false;
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

  /// Critical section (even for between foreground and background service)
  @override
  Future<bool> internalExecute(Queue<InAppWebViewController> controllers) async {
    var controller = controllers.removeFirst();

    if (isLogin) {
      await copyCredentials(controller);
      return true;
    }

    if (_future != null) {
      final transaction = parentTransaction?.startChild("${getTaskId()}_share");
      var res = await _future!;
      if (!res) return false;
      await copyCredentials(controller);
      transaction?.finish(status: res ? const SpanStatus.ok() : const SpanStatus.unauthenticated());
      return res;
    }

    _isLogin = false;
    _isFail = false;
    Value<String>? cause;

    var completer = Completer<bool>();
    _future = completer.future;
    var fail = false;

    final transaction = parentTransaction?.startChild(getTaskId()) ?? Sentry.startTransaction('Login', getTaskId());
    late ISentrySpan span;

    controller.jsAlertCallback = (String? reason) {
      fail = true;

      if (reason != null) {
        cause = Value(reason);
      }
    };

    span = transaction.startChild("clear_cookie");
    var cookie = CookieManager.instance();
    await cookie.deleteAllCookies();
    span.finish(status: const SpanStatus.ok());

    if (!isBackground) await updateBackgroundService(lazy: true);

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
    while (!(await controller.getUrl()).toString().startsWith("https://saint.ssu.ac.kr/irj/portal")) {
      await Future.delayed(Duration.zero);
    }
    span.finish(status: fail ? const SpanStatus.cancelled() : const SpanStatus.ok());

    await controller.customLoadPage("https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW1001n?sap-language=KO"); // loads any page

    _credentials = await CookieManager.instance().getCookies(url: WebUri(".ssu.ac.kr"));

    controller.jsAlertCallback = (_) {};

    span = transaction.startChild("broadcast_event");
    _future = null;
    if (fail) {
      _isFail = true;
      loginFailEvent.broadcast(cause);
    }

    var res = !fail;
    loginStatusChangeEvent.broadcast(Value(res));
    span.finish(status: const SpanStatus.ok());

    transaction.finish(status: const SpanStatus.ok());

    _isLogin = res;
    completer.complete(_isLogin);

    return _isLogin;
  }

  @override
  String toString() => "$runtimeType(id=$id, password=$password)";

  @override
  int getTimeout() {
    return 20;
  }

  @override
  String getTaskId() {
    return "login";
  }
}
