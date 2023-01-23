import 'dart:async';

import 'package:flutter/material.dart';
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
  static const int webViewCount = 3;
  final List<Future<void>> _webViewInitialized = [];
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

      setState(() {
        _progress = MainProgress.finish;
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
                            ]),
                  ),
                ),
              ),
            ),
          ],
    );
  }
}
