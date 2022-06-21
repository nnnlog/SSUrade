import 'dart:convert';
import 'dart:developer';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ssurade/types/SubjectData.dart';
import 'package:ssurade/utils/toast.dart';

import '../globals.dart' as globals;

class USaintSession {
  String _number, _password;
  bool _isLogin = false;

  USaintSession(this._number, this._password);

  bool get isNotEmpty {
    return number.isNotEmpty && password.isNotEmpty;
  }

  String get number {
    return _number;
  }

  set number(String number) {
    _isLogin = false;
    _number = number;
  }

  String get password {
    return _password;
  }

  set password(String password) {
    _isLogin = false;
    _password = password;
  }

  bool get isLogin {
    return _isLogin;
  }

  bool _lockedForLogin = false;

  Future<bool> tryLogin({bool refresh = false}) async {
    if (refresh) _isLogin = false;
    if (isLogin) return true;
    if (_lockedForLogin) return false;

    _lockedForLogin = true;
    var fail = false;
    globals.jsAlertCallback = () {
      fail = true;
    };

    var res = await Future.any(
      [
        Future(() async {
          await globals.webViewController.loadData(data: "<html></html>");
          await globals.webViewController.loadUrl(
              urlRequest: URLRequest(
                  url: Uri.parse("https://smartid.ssu.ac.kr/Symtra_sso/smln.asp?apiReturnUrl=https%3A%2F%2Fsaint.ssu.ac.kr%2FwebSSO%2Fsso.jsp")));

          await Future.doWhile(globals.webViewController.isLoading);

          while ((await globals.webViewController.evaluateJavascript(source: 'document.getElementById("userid")?.value')) != number) {
            await globals.webViewController
                .evaluateJavascript(source: 'document.getElementById("userid").value = atob("${base64Encode(utf8.encode(number))}");');
            await Future.delayed(const Duration(milliseconds: 300));
          }
          while ((await globals.webViewController.evaluateJavascript(source: 'document.getElementById("pwd")?.value')) != password) {
            await globals.webViewController
                .evaluateJavascript(source: 'document.getElementById("pwd").value = atob("${base64Encode(utf8.encode(password))}");');
            await Future.delayed(const Duration(milliseconds: 300));
          }

          await globals.webViewController.evaluateJavascript(source: 'document.querySelector("*[class=btn_login]").click();');

          while (!fail && (await globals.webViewController.getUrl()).toString().startsWith("https://smartid.ssu.ac.kr/")) {
            await Future.delayed(const Duration(milliseconds: 300));
          }

          return !fail;
        }),
        Future.delayed(const Duration(seconds: 10), () => false),
      ],
    );

    globals.jsAlertCallback = () {};
    _lockedForLogin = false;

    return _isLogin = res;
  }

  bool _lockedForGrade = false;

  fetchGrade() async {
    if (_lockedForGrade) return false;
    _lockedForGrade = true;

    List<SubjectData> result = [];
    try {
      if (!await tryLogin()) {
        return false;
      }

      await globals.webViewController
          .loadUrl(urlRequest: URLRequest(url: Uri.parse("https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMB3W0017?sap-language=KO")));

      dynamic temp = "";
      while (temp.length == 0) {
        try {
          temp = await globals.webViewController.evaluateJavascript(source: '''
              if (document.querySelectorAll(`#WD0133-contentTBody tr`).length >= 2) {
                let ret = [];
                for (let i = 2; i <= document.querySelectorAll(`#WD0133-contentTBody tr`).length; i++) {
                  ret.push([
                    document.querySelector(`#WD0133-contentTBody tr:nth-child(\${i}) td:nth-child(5) span span`).textContent, // 과목명
                    document.querySelector(`#WD0133-contentTBody tr:nth-child(\${i}) td:nth-child(6) span span`).textContent, // 학점 (이수 단위)
                    document.querySelector(`#WD0133-contentTBody tr:nth-child(\${i}) td:nth-child(8) span span`).textContent, // 학점 (등급)
                    document.querySelector(`#WD0133-contentTBody tr:nth-child(\${i}) td:nth-child(9) span span`).textContent, // 교수명
                  ]);
                }
                JSON.stringify(ret.map(a => a.map(b => b.trim())));
              }
              ''');
          temp ??= "";
          temp = temp.trim();
        } catch (e) {
          await Future.delayed(const Duration(milliseconds: 300));
          continue;
        }
      }
      temp = jsonDecode(temp);

      for (var obj in temp) {
        result.add(SubjectData(obj[0], double.parse(obj[1]), obj[2], obj[3]));
      }
    } catch (e) {
      log(e.toString());
      _isLogin = false;
      return false;
    } finally {
      _lockedForGrade = false;
    }

    return result;
  }

  @override
  String toString() => "USaintSession(number=$number, password=$password)";
}
