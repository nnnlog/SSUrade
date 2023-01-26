import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:ssurade/components/BackgroundWebView.dart';
import 'package:ssurade/components/CustomAppBar.dart';
import 'package:ssurade/crawling/Crawler.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/Progress.dart';
import 'package:ssurade/utils/toast.dart';
import 'package:ssurade/utils/update.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const int webViewCount = 5;
  final List<Future<void>> _webViewInitialized = [];
  final Completer<void> _agreeFuture = Completer();
  late String _agreement, _agreement_short;
  MainProgress _progress = MainProgress.init;

  @override
  void initState() {
    super.initState();

    (() async {
      await Future.wait(_webViewInitialized);

      Crawler.loginSession().loginStatusChangeEvent.subscribe((args) {
        setState(() {});

        // add analytics?
      });

      Crawler.loginSession().loginFailEvent.subscribe((msg) {
        showToast("로그인을 실패했습니다.");
        // showToast("메인 화면에서 자동 로그인을 다시 시도하거나 새로운 계정으로 로그인하세요.");

        if (msg != null) {
          showToast(msg.value);
        }

        globals.analytics.logEvent(name: "login_fail");
      });

      await globals.init();

      if (!globals.setting.agree) {
        _agreement = await rootBundle.loadString("assets/agreement.txt");
        _agreement_short = await rootBundle.loadString("assets/agreement_short.txt");
        setState(() {
          _progress = MainProgress.agree;
        });
        await _agreeFuture.future;
      }

      setState(() {
        _progress = MainProgress.finish;
      });

      if (Crawler.loginSession().isNotEmpty) {
        Crawler.loginSession().execute().then((value) {
          if (value) {
            showToast("자동 로그인했습니다.");

            globals.analytics.logEvent(name: "login", parameters: {"auto_login": "true"});
          }
        });
      }

      fetchAppVersion().then((value) {
        if (value.item2 != "") {
          showToast("새로운 버전 v${value.item2}(으)로 업데이트할 수 있습니다.");
        }
      });

      Crawler.allGrade(base: globals.semesterSubjectsManager).execute().then((value) {
        // base가 주어져도 grade by category가 overwrite하도록 바꿔야 함
        if (value == null) return;
        bool update = false;
        for (var key in value.data.keys) {
          if (!globals.semesterSubjectsManager.data.containsKey(key)) {
            update = true;
            globals.semesterSubjectsManager.data[key] = value.data[key]!;
          }
        }

        if (update) {
          showToast("새로운 학기 성적을 찾았습니다.");
          globals.newGradeFoundEvent.broadcast();
        }
      });
    })();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.filled(webViewCount, null).map<Widget>((e) => BackgroundWebView(_webViewInitialized)).toList() +
          <Widget>[
            Scaffold(
              appBar: customAppBar("숭실대학교 성적/학점 조회"),
              body: Padding(
                padding: const EdgeInsets.all(30),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: (_progress == MainProgress.init
                        ? <Widget>[
                            const LinearProgressIndicator(),
                            const SizedBox(
                              width: 1,
                              height: 15,
                            ),
                            const Text("정보를 불러오고 있어요..."),
                          ]
                        : (_progress == MainProgress.agree
                            ? <Widget>[
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "SSUrade 개인정보 처리방침",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 30,
                                      ),
                                      SingleChildScrollView(
                                        child: Text(_agreement_short),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      TextButton(
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: const Size.fromHeight(40),
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return StatefulBuilder(builder: (BuildContext context, StateSetter setStateDialog) {
                                                return Dialog(
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(25, 25, 20, 15),
                                                    child: Column(
                                                      children: [
                                                        Flexible(
                                                          child: ListView(
                                                            shrinkWrap: true,
                                                            children: [
                                                              SingleChildScrollView(
                                                                child: Text(_agreement),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        TextButton(
                                                          style: ElevatedButton.styleFrom(
                                                            minimumSize: const Size.fromHeight(40),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                          },
                                                          child: const Text("닫기"),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              });
                                            },
                                          );
                                        },
                                        child: const Text(
                                          "전체 보기",
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 50,
                                      ),
                                    ],
                                  ),
                                ),
                                IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          showToast("동의하지 않으면 앱을 사용할 수 없어요.");
                                          FlutterExitApp.exitApp(iosForceExit: true);
                                        },
                                        child: const Text("닫기"),
                                      ),
                                      const Spacer(),
                                      FilledButton(
                                        onPressed: () {
                                          globals.setting.agree = true;
                                          globals.setting.saveFile();

                                          _agreeFuture.complete();
                                        },
                                        child: const Text("동의 후 계속하기"),
                                      ),
                                    ],
                                  ),
                                ),
                              ]
                            : <Widget>[
                                  Visibility(
                                    visible: Crawler.loginSession().isNotEmpty,
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        Navigator.pushNamed(context, "/grade_view");
                                      },
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size.fromHeight(40),
                                      ),
                                      child: const Text("학기별 성적 조회"),
                                    ),
                                  ),
                                  Visibility(
                                    visible: Crawler.loginSession().isEmpty || Crawler.loginSession().isFail, // 자동 로그인 실패했거나 로그인이 필요하면
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, "/login");
                                      },
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size.fromHeight(40),
                                      ),
                                      child: const Text("로그인"),
                                    ),
                                  ),
                                  Visibility(
                                    visible: Crawler.loginSession().isNotEmpty && Crawler.loginSession().isFail, // 자동 로그인 실패했을 때
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        if (await Crawler.loginSession().execute()) {
                                          showToast("자동 로그인했습니다.");
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size.fromHeight(40),
                                      ),
                                      child: const Text("자동 로그인 재시도"),
                                    ),
                                  ),
                                ] +
                                <Widget>[
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, "/setting");
                                    },
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(40),
                                    ),
                                    child: const Text("설정"),
                                  ),
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, "/information");
                                    },
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(40),
                                    ),
                                    child: const Text("정보"),
                                  ),
                                ])),
                  ),
                ),
              ),
            ),
          ],
    );
  }
}
