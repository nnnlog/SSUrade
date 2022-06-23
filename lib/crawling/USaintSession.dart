import 'dart:convert';
import 'dart:developer';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ssurade/types/Progress.dart';
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

  logout() {
    number = "";
    password = "";
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

    bool res;
    try {
      res = await Future.any(
        [
          Future(() async {
            var cookie = CookieManager.instance();
            await cookie.deleteAllCookies();

            await globals.webViewController.loadData(data: "");
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
          Future.delayed(const Duration(seconds: 5), () => false),
        ],
      );
    } catch (e) {
      log(e.toString());
      res = false;
    }

    globals.jsAlertCallback = () {};
    _lockedForLogin = false;

    return _isLogin = res;
  }

  bool _lockedForGrade = false;

  Future<SubjectDataList?> fetchGrade() async {
    if (_lockedForGrade) return null;
    _lockedForGrade = true;

    late SubjectDataList? result;
    try {
      result = await Future.any([
        Future(() async {
          if (!await tryLogin()) {
            return null;
          }

          // DateTime time = DateTime.now();
          await globals.webViewController.loadData(data: "");
          globals.webViewXHRTotalCount = 0; // reset
          globals.webViewXHRRunningCount = 0; // reset

          // showToast("load (init) : ${DateTime.now().difference(time).inMilliseconds}ms");
          // time = DateTime.now();

          await globals.webViewController
              .loadUrl(urlRequest: URLRequest(url: Uri.parse("https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMB3W0017?sap-language=KO")));

          // showToast("load (page) : ${DateTime.now().difference(time).inMilliseconds}ms");
          // time = DateTime.now();

          // 페이지 로딩 직후 XHR 요청이 모두 완료될 때까지 대기
          bool existXHR = await Future.any([
            Future(() async {
              await Future.doWhile(() async {
                await Future.delayed(const Duration(milliseconds: 10));
                return globals.webViewXHRTotalCount == 0;
              });
              return true;
            }),
            Future.delayed(const Duration(seconds: 3), () => false)
          ]);
          // showToast("existXHR : ${DateTime.now().difference(time).inMilliseconds}ms");
          // time = DateTime.now();
          if (existXHR) {
            await Future.any([
              Future.doWhile(() async {
                await Future.delayed(const Duration(milliseconds: 10));
                return globals.webViewXHRRunningCount > 0;
              }),
              Future.delayed(const Duration(seconds: 5))
            ]);
          } else {
            log("XHR 로딩 없음");
          }

          // showToast("finishXHR : ${DateTime.now().difference(time).inMilliseconds}ms");
          // time = DateTime.now();

          // 학기 드롭다운(dropdown)에서 1학기 선택
          globals.webViewXHRProgress = XHRProgress.ready;
          await Future.doWhile(() async {
            try {
              await globals.webViewController.evaluateJavascript(
                  source: 'document.querySelectorAll("table table table table")[12].querySelector("td:nth-child(5) span").click();');
              await Future.delayed(const Duration(milliseconds: 100));
              await globals.webViewController.evaluateJavascript(
                  source:
                      'document.querySelector("div div div div:nth-child(3) div div:nth-child(2) div:nth-child(2) div div div:nth-child(1)").click();');
              await Future.delayed(const Duration(milliseconds: 100));

              var selected = (await globals.webViewController.evaluateJavascript(
                  source:
                      'document.querySelectorAll("table table table table")[12].querySelector("td:nth-child(5) span")?.querySelector("*[value]").value;'));
              if (selected == null) return true;
              selected = selected.replaceAll(" ", "");

              return selected != "1학기";
            } catch (e, s) {
              // showToast("error : ${e.toString()} (${s.toString()}");
              return true;
            }
          });
          // showToast("select 1st : ${DateTime.now().difference(time).inMilliseconds}ms");
          // time = DateTime.now();

          // 현재 학기 정보가 모두 로딩될 때까지 대기
          await Future.any([
            Future.doWhile(() async {
              await Future.delayed(const Duration(milliseconds: 10));
              return globals.webViewXHRProgress != XHRProgress.finish;
            }),
            Future.delayed(const Duration(seconds: 5))
          ]);
          globals.webViewXHRProgress = XHRProgress.none;

          // showToast("load 1st : ${DateTime.now().difference(time).inMilliseconds}ms");
          // time = DateTime.now();

          dynamic temp = "";
          while (temp.length == 0) {
            try {
              temp = await globals.webViewController.evaluateJavascript(source: '''
              let elements = document.querySelectorAll(`table tr table tr table tr:nth-child(11) td table table table table tbody:nth-child(2) tr`);
              if (elements.length >= 1) { // XHR 상태보고 하는거라 필요없긴 함
                let ret = [];
                for (let i = 1; i < elements.length; i++) {
                  ret.push([
                    elements[i].querySelector(`td:nth-child(5) span span`).textContent, // 과목명
                    elements[i].querySelector(`td:nth-child(6) span span`).textContent, // 학점 (이수 단위)
                    elements[i].querySelector(`td:nth-child(8) span span`).textContent, // 학점 (등급)
                    elements[i].querySelector(`td:nth-child(9) span span`).textContent, // 교수명
                  ]);
                }
                JSON.stringify(ret.map(a => a.map(b => b.trim())));
              }
              ''');
              temp ??= "";
              temp = temp.trim();
            } catch (e, stacktrace) {
              log(e.toString());
              log(stacktrace.toString());
              await Future.delayed(const Duration(milliseconds: 100));
              continue;
            }
          }
          // showToast("finish : ${DateTime.now().difference(time).inMilliseconds}ms");
          // time = DateTime.now();
          temp = jsonDecode(temp);

          SubjectDataList result = SubjectDataList([]);
          for (var obj in temp) {
            result.subjectData.add(SubjectData(obj[0], double.parse(obj[1]), obj[2], obj[3]));
          }
          result.subjectData.sort((a, b) => a.grade.length < b.grade.length ? 1 : -1); // 학점 나온거부터 위로 오게

          return result;
        }),
        Future.delayed(const Duration(seconds: 20), () => null),
      ]);
    } catch (e) {
      log(e.toString());
      globals.setStateOfMainPage(() {
        _isLogin = false;
      });

      return null;
    } finally {
      _lockedForGrade = false;
    }

    return result;
  }

  @override
  String toString() => "USaintSession(number=$number, password=$password)";
}
