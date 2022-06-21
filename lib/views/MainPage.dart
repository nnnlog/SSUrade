import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ssurade/crawling/USaintSession.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/MainProgress.dart';
import 'package:ssurade/utils/toast.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  MainProgress progress = MainProgress.init;

  @override
  void initState() {
    super.initState();

    (() async {
      globals.setStateOfMainPage = setState;

      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        return !globals.webViewInitialized;
      });

      await globals.init();

      var setting = globals.setting;
      if (setting.saintSession.isNotEmpty) {
        if (!await setting.saintSession.tryLogin()) {
          showToast("자동로그인을 실패했습니다.");
        } else {
          showToast("자동로그인했습니다.");
        }
      }

      globals.setStateOfMainPage(() {
        progress = MainProgress.finish;
      });
    })();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: 1,
          height: 1,
          child: InAppWebView(
            onWebViewCreated: (controller) {
              globals.webViewController = controller;
              globals.webViewInitialized = true;
            },
            onJsAlert: (controller, action) async {
              globals.jsAlertCallback();
            },
            onJsConfirm: (controller, action) async {
              return JsConfirmResponse(); // cancel confirm event
            },
            onJsPrompt: (controller, action) async {
              return JsPromptResponse(); // cancel prompt event
            },
          ),
        ),
        Scaffold(
          appBar: AppBar(
            title: const Text("숭실대학교 학점 조회"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: progress == MainProgress.init
                    ? [
                        const LinearProgressIndicator(),
                        const Text("정보를 불러오고 있습니다..."),
                      ]
                    : (globals.setting.saintSession.isLogin
                        ? [
                            OutlinedButton(
                              onPressed: () async {
                                showToast((await globals.setting.saintSession.fetchGrade()).toString());
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(40),
                              ),
                              child: const Text("테스트"),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  globals.setting.saintSession = USaintSession("", "");
                                  globals.setting.saveFile();
                                  showToast("로그아웃했습니다.");
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(40),
                              ),
                              child: const Text("로그아웃"),
                            ),
                          ]
                        : [
                            OutlinedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/login");
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(40),
                              ),
                              child: const Text("로그인"),
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
