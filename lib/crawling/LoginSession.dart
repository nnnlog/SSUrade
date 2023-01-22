import 'dart:convert';
import 'dart:developer';

import 'package:event/event.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade/crawling/CrawlingTask.dart';
import 'package:ssurade/crawling/WebViewControllerExtension.dart';
import 'package:ssurade/filesystem/FileSystem.dart';

part 'LoginSession.g.dart';

/// U-Saint Session Manager
/// All WebView Controller share same CookieManager, so need only one instance for managing login session.
/// Provide Event
@JsonSerializable(constructor: "_")
class LoginSession extends CrawlingTask<bool> {
  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  Event<Value<bool>> event = Event(); // broadcast event when login status change

  static final LoginSession _instance = LoginSession._("", "");

  static LoginSession get() {
    return _instance;
  }

  @JsonKey(
    includeFromJson: true,
    includeToJson: true,
  )
  String _id;

  @JsonKey(
    includeFromJson: true,
    includeToJson: true,
  )
  String _password;

  LoginSession._(this._id, this._password);

  factory LoginSession.fromJson(Map<String, dynamic> json) => _$LoginSessionFromJson(json);

  Map<String, dynamic> toJson() => _$LoginSessionToJson(this);

  static const String _filename = "credential.json"; // internal file name

  /// Singleton
  Future loadFromFile() async {
    late LoginSession tmp;
    try {
      dynamic json = {};
      if (await existFile(_filename)) {
        json = jsonDecode((await readFile(_filename))!);
      }
      tmp = LoginSession.fromJson(json);
    } catch (e) {
      tmp = LoginSession._("", "");
    }
    id = tmp.id;
    password = tmp.password;
  }

  saveFile() => writeFile(_filename, jsonEncode(toJson()));

  bool _isLogin = false;

  bool get isEmpty {
    return _id.isEmpty || _password.isEmpty;
  }

  bool get isNotEmpty {
    return !isEmpty;
  }

  bool get isLogin {
    return _isLogin;
  }

  @JsonKey(
    includeToJson: false,
    includeFromJson: false,
  )
  get id {
    return _id;
  }

  set id(value) {
    _id = value;
    _isLogin = false;
  }

  @JsonKey(
    includeToJson: false,
    includeFromJson: false,
  )
  get password {
    return _password;
  }

  set password(value) {
    _password = value;
    _isLogin = false;
  }

  logout() {
    id = password = "";
    event.broadcast(Value(_isLogin)); // false
  }

  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  Future<bool>? _future;

  @override
  Future<bool> directExecute(InAppWebViewController controller) async {
    if (isLogin) return true;
    if (_future != null) return _future!;

    return _future = Future(() async {
      var fail = false;
      controller.jsAlertCallback = () {
        fail = true;
      };

      bool res;
      try {
        res = await Future.any(
          [
            Future(() async {
              var cookie = CookieManager.instance();
              await cookie.deleteAllCookies();

              await controller.loadUrl(
                  urlRequest: URLRequest(
                      url: Uri.parse("https://smartid.ssu.ac.kr/Symtra_sso/smln.asp?apiReturnUrl=https%3A%2F%2Fsaint.ssu.ac.kr%2FwebSSO%2Fsso.jsp")));

              await Future.doWhile(controller.isLoading);

              while ((await controller.evaluateJavascript(source: 'document.getElementById("userid")?.value')) != _id) {
                await controller.evaluateJavascript(source: 'document.getElementById("userid").value = atob("${base64Encode(utf8.encode(_id))}");');
                await Future.delayed(const Duration(milliseconds: 10));
              }
              while ((await controller.evaluateJavascript(source: 'document.getElementById("pwd")?.value')) != _password) {
                await controller.evaluateJavascript(
                    source: 'document.getElementById("pwd").value = atob("${base64Encode(utf8.encode(_password))}");');
                await Future.delayed(const Duration(milliseconds: 10));
              }

              await controller.evaluateJavascript(source: 'document.querySelector("*[class=btn_login]").click();');

              while (!fail && (await controller.getUrl()).toString().startsWith("https://smartid.ssu.ac.kr/")) {
                await Future.delayed(const Duration(milliseconds: 10));
              }

              return !fail;
            }),
            Future.delayed(const Duration(seconds: 5), () => false),
          ],
        );
      } catch (e) {
        log(e.toString());
        res = false;
      }

      controller.jsAlertCallback = () {};

      _future = null;

      event.broadcast(Value(res));
      return _isLogin = res;
    });
  }

  @override
  String toString() => "$runtimeType(id=$id, password=$password)";
}
