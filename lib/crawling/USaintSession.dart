import 'dart:convert';
import 'dart:developer';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ssurade/types/Progress.dart';
import 'package:ssurade/types/Semester.dart';
import 'package:ssurade/types/SubjectData.dart';
import 'package:ssurade/utils/toast.dart';
import 'package:tuple/tuple.dart';

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

  bool _lockedForWebView = false;

  Future<bool> tryLogin({bool refresh = false}) async {
    if (refresh) _isLogin = false;
    if (isLogin) return true;
    if (_lockedForWebView) return false;

    _lockedForWebView = true;
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
    _lockedForWebView = false;

    return _isLogin = res;
  }

  _initForXHR({bool clearCache = true}) async {
    if (clearCache) {
      var cookie = await CookieManager.instance().getCookies(url: Uri.parse("https://ssu.ac.kr"));

      await globals.webViewController.clearCache();

      for (var obj in cookie) {
        await CookieManager.instance().setCookie(
            url: Uri.parse("https://ssu.ac.kr"),
            name: obj.name,
            value: obj.value,
            domain: obj.domain,
            expiresDate: obj.expiresDate,
            isHttpOnly: obj.isHttpOnly,
            isSecure: obj.isSecure,
            sameSite: obj.sameSite);
      }
    }

    globals.webViewXHRTotalCount = 0; // reset
    globals.webViewXHRRunningCount = 0; // reset
  }

  _waitForXHR() async {
    bool existXHR = await Future.any([
      Future(() async {
        await Future.doWhile(() async {
          await Future.delayed(const Duration(milliseconds: 10));
          return globals.webViewXHRTotalCount == 0;
        });
        return true;
      }),
      Future.delayed(const Duration(seconds: 5), () => false)
    ]);

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
  }

  Future<Tuple2<String, String>?> getEntranceGraduateYear() async {
    if (_lockedForWebView) return null;
    _lockedForWebView = true;

    bool isFinished = false;

    late Tuple2<String, String>? result;
    try {
      result = await Future.any([
        Future(() async {
          if (isFinished) return null;
          if (!await tryLogin()) {
            return null;
          }

          await _initForXHR();

          await globals.webViewController
              .loadUrl(urlRequest: URLRequest(url: Uri.parse("https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMW1001n?sap-language=KO")));

          await _waitForXHR();

          await Future.any([
            Future.doWhile(() async {
              if (isFinished) return false;
              try {
                String? entrance = await globals.webViewController.evaluateJavascript(
                    source:
                        'document.querySelectorAll("table tr div div:nth-child(1) span span:nth-child(2) tbody:nth-child(2) tr td span span table tbody tr:nth-child(1) td:nth-child(1) table tr table tr:nth-child(1) td:nth-child(2) span input")[0].value;');
                if (entrance == null) return true;
                entrance = entrance.trim();
                if (entrance.isEmpty) return true;

                String? graduate = await globals.webViewController.evaluateJavascript(
                    source:
                        'document.querySelectorAll("table tr div div:nth-child(1) span span:nth-child(2) tbody:nth-child(2) tr td span span table tbody tr:nth-child(1) td:nth-child(1) table tr table tr:nth-child(1) td:nth-child(2) span input")[0].value;');
                if (graduate == null) return true;
                graduate = graduate.trim();
                if (graduate.isEmpty) return true;

                result = Tuple2(entrance, graduate);
                return false;
              } catch (e, stacktrace) {
                log(e.toString());
                log(stacktrace.toString());
                await Future.delayed(const Duration(milliseconds: 100));
                return true;
              }
            }),
            Future.delayed(const Duration(seconds: 5))
          ]);

          return result;
        }),
        Future.delayed(const Duration(seconds: 10), () => null),
      ]);
    } catch (e) {
      log(e.toString());
      globals.setStateOfMainPage(() {
        _isLogin = false;
      });

      return null;
    } finally {
      _lockedForWebView = false;
      isFinished = true;
    }

    return result;
  }

  Future<String?> getEntranceYear() async {
    return (await getEntranceGraduateYear())?.item1;
  }

  Future<String?> getGraduateYear() async {
    return (await getEntranceGraduateYear())?.item2;
  }

  Future<SubjectDataList?> getGrade(YearSemester search, {bool reloadPage = true}) async {
    if (_lockedForWebView) return null;
    _lockedForWebView = true;

    bool isFinished = false;

    late SubjectDataList? result;
    try {
      result = await Future.any([
        Future(() async {
          if (!await tryLogin()) {
            return null;
          }

          // DateTime time = DateTime.now();

          var url = (await globals.webViewController.getUrl()).toString();
          if (url.contains("#")) {
            url = url.substring(0, url.indexOf("#"));
          }

          if (reloadPage || url != "https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMB3W0017?sap-language=KO") {
            await _initForXHR();
            // showToast("init (xhr) : ${DateTime.now().difference(time).inMilliseconds}ms");
            // log("init (xhr) : ${DateTime.now().difference(time).inMilliseconds}ms");
            // time = DateTime.now();

            await globals.webViewController
                .loadUrl(urlRequest: URLRequest(url: Uri.parse("https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMB3W0017?sap-language=KO")));
            // showToast("load (page) : ${DateTime.now().difference(time).inMilliseconds}ms");
            // log("load (page) : ${DateTime.now().difference(time).inMilliseconds}ms");
            // time = DateTime.now();

            await _waitForXHR();
            // showToast("finishXHR : ${DateTime.now().difference(time).inMilliseconds}ms");
            // log("finishXHR : ${DateTime.now().difference(time).inMilliseconds}ms");
            // time = DateTime.now();
          }

          // 학년도 드롭다운(dropdown)에서 학년도 선택
          globals.webViewXHRProgress = XHRProgress.ready;
          bool existXHR = false;
          await Future.doWhile(() async {
            if (isFinished) return false;
            try {
              var selected = (await globals.webViewController.evaluateJavascript(
                  source:
                      'document.querySelectorAll("table table table table")[12].querySelector("td:nth-child(2) span")?.querySelector("*[value]").value;'));
              if (selected?.replaceAll(" ", "") == "${search.year}학년도") return false;
              existXHR = true;

              await globals.webViewController.evaluateJavascript(
                  source: 'document.querySelectorAll("table table table table")[12].querySelector("td:nth-child(2) span").click();');
              await Future.delayed(const Duration(milliseconds: 100));
              await globals.webViewController
                  .evaluateJavascript(source: 'document.querySelector("div[data-itemvalue1=\'${search.year}학년도\']").click();');
              await Future.delayed(const Duration(milliseconds: 100));
            } catch (e, s) {
              // showToast("error : ${e.toString()} (${s.toString()}");
            }
            return true;
          });
          // showToast("select year : ${DateTime.now().difference(time).inMilliseconds}ms");
          // log("select year : ${DateTime.now().difference(time).inMilliseconds}ms");
          // time = DateTime.now();

          if (existXHR) {
            await Future.any([
              Future.doWhile(() async {
                await Future.delayed(const Duration(milliseconds: 10));
                return globals.webViewXHRProgress != XHRProgress.finish;
              }),
              Future.delayed(const Duration(seconds: 3))
            ]);
            // showToast("load year : ${DateTime.now().difference(time).inMilliseconds}ms");
            // log("load year : ${DateTime.now().difference(time).inMilliseconds}ms");
            // time = DateTime.now();
          }

          // 학기 드롭다운(dropdown)에서 학기 선택
          globals.webViewXHRProgress = XHRProgress.ready;
          existXHR = false;
          await Future.doWhile(() async {
            if (isFinished) return false;
            try {
              var selected = (await globals.webViewController.evaluateJavascript(
                  source:
                      'document.querySelectorAll("table table table table")[12].querySelector("td:nth-child(5) span")?.querySelector("*[value]").value;'));
              if (selected?.replaceAll(" ", "") == search.semester.name) return false;
              existXHR = true;

              await globals.webViewController.evaluateJavascript(
                  source: 'document.querySelectorAll("table table table table")[12].querySelector("td:nth-child(5) span").click();');
              await Future.delayed(const Duration(milliseconds: 100));
              await globals.webViewController.evaluateJavascript(
                  source:
                      'document.querySelector("div div div div:nth-child(3) div div:nth-child(2) div:nth-child(2) div div div:nth-child(${search.semester.webIndex})").click();');
              await Future.delayed(const Duration(milliseconds: 100));
            } catch (e, s) {
              // showToast("error : ${e.toString()} (${s.toString()}");
            }
            return true;
          });
          // showToast("select sem : ${DateTime.now().difference(time).inMilliseconds}ms");
          // log("select sem : ${DateTime.now().difference(time).inMilliseconds}ms");
          // time = DateTime.now();

          // 현재 학기 정보가 모두 로딩될 때까지 대기
          if (existXHR) {
            await Future.any([
              Future.doWhile(() async {
                if (isFinished) return false;
                await Future.delayed(const Duration(milliseconds: 10));
                return globals.webViewXHRProgress != XHRProgress.finish;
              }),
              Future.delayed(const Duration(seconds: 5))
            ]);
          }
          // showToast("load sem : ${DateTime.now().difference(time).inMilliseconds}ms");
          // log("load sem : ${DateTime.now().difference(time).inMilliseconds}ms");
          // time = DateTime.now();

          dynamic temp = "";
          await Future.any([
            Future.doWhile(() async {
              if (isFinished) return false;
              try {
                temp = await globals.webViewController.evaluateJavascript(source: '''
                JSON.stringify(
                  Array(...document.querySelectorAll(`table tr table tr table tr:nth-child(11) td table table table table tbody:nth-child(2) tr`))
                    .slice(1).map(element => [
                      element.querySelector(`td:nth-child(5) span span`).textContent.trim(), // 과목명
                      element.querySelector(`td:nth-child(6) span span`).textContent.trim(), // 학점 (이수 단위)
                      element.querySelector(`td:nth-child(8) span span`).textContent.trim(), // 학점 (등급)
                      element.querySelector(`td:nth-child(9) span span`).textContent.trim(), // 교수명
                    ]
                  )
                );
              ''');

                temp ??= "";
                temp = temp.trim();
                return temp.isEmpty;
              } catch (e, stacktrace) {
                log(e.toString());
                log(stacktrace.toString());
                await Future.delayed(const Duration(milliseconds: 100));
                return true;
              }
            }),
            Future.delayed(const Duration(seconds: 5))
          ]);
          // showToast("finish : ${DateTime.now().difference(time).inMilliseconds}ms");
          // log("finish : ${DateTime.now().difference(time).inMilliseconds}ms");
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
    } catch (e, stacktrace) {
      log(e.toString());
      log(stacktrace.toString());
      globals.setStateOfMainPage(() {
        _isLogin = false;
      });

      return null;
    } finally {
      _lockedForWebView = false;
      isFinished = true;
    }

    return result;
  }

  Future<Map<YearSemester, SubjectDataList>?> getAllGrade() async {
    bool isFinished = false;

    late Map<YearSemester, SubjectDataList>? result;
    try {
      result = await Future.any([
        Future(() async {
          if (!await tryLogin()) {
            return null;
          }

          result = {};

          int entranceYear = int.parse((await getEntranceYear())!);
          String rawGraduateYear = (await getGraduateYear())!;
          int graduateYear;
          if (rawGraduateYear == "0000") { // 재학 중?
            graduateYear = int.parse(YearSemester.current().year);
          } else {
            graduateYear = int.parse(rawGraduateYear);
          }

          for (var i = entranceYear; i <= graduateYear; i++) {
            for (var semester in Semester.values) {
              YearSemester key = YearSemester(i.toString(), semester);
              result![key] = (await getGrade(key, reloadPage: false))!;

              if (result![key]?.subjectData.isEmpty == true) {
                result!.remove(key);
              }
            }
          }

          return result;
        }),
        Future.delayed(const Duration(seconds: 30), () => null),
      ]);
    } catch (e, stacktrace) {
      log(e.toString());
      log(stacktrace.toString());

      globals.setStateOfMainPage(() {
        _isLogin = false;
      });

      return null;
    } finally {
      isFinished = true;
    }

    return result;
  }

  @override
  String toString() => "USaintSession(number=$number, password=$password)";
}