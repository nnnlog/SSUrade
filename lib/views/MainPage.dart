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

      Crawler.loginSession().event.subscribe((args) {
        setState(() {});
      });

      await globals.init();
      Future(() async {
        if (Crawler.loginSession().isNotEmpty) {
          if (!await Crawler.loginSession().execute()) {
            showToast("자동로그인을 실패했습니다.");
          } else {
            showToast("자동로그인했습니다.");
          }
        }

        setState(() {
          _progress = MainProgress.finish;
        });
      });

      await fetchAppVersion().then((value) {
        if (value.item2 != "") {
          showToast("새로운 버전 v${value.item2}(으)로 업데이트할 수 있습니다.");
        }
      });
    })();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.filled(webViewCount, null).map<Widget>((e) => BackgroundWebView(_webViewInitialized)).toList() +
          [
            Scaffold(
              appBar: customAppBar("숭실대학교 성적/학점 조회"),
              body: Padding(
                padding: const EdgeInsets.all(30),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _progress == MainProgress.init
                        ? <Widget>[
                            const LinearProgressIndicator(),
                            const SizedBox(
                              width: 1,
                              height: 15,
                            ),
                            const Text("자동로그인 중 입니다..."),
                          ]
                        : ((Crawler.loginSession().isLogin
                                ? <Widget>[
                                    OutlinedButton(
                                      onPressed: () async {
                                        Navigator.pushNamed(context, "/view");
                                      },
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size.fromHeight(40),
                                      ),
                                      child: const Text("성적/학점 조회"),
                                    ),
                                  ]
                                : <Widget>[
                                    OutlinedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, "/login");
                                      },
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size.fromHeight(40),
                                      ),
                                      child: const Text("로그인"),
                                    ),
                                    Crawler.loginSession().isNotEmpty
                                        ? OutlinedButton(
                                            onPressed: () async {
                                              if (!await Crawler.loginSession().execute()) {
                                                showToast("자동로그인을 실패했습니다.");
                                              } else {
                                                showToast("자동로그인했습니다.");
                                                setState(() {});
                                              }
                                            },
                                            style: OutlinedButton.styleFrom(
                                              minimumSize: const Size.fromHeight(40),
                                            ),
                                            child: const Text("자동로그인 재시도"),
                                          )
                                        : Container(),
                                  ]) +
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
