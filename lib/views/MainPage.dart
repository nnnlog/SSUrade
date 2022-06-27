import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ssurade/components/CustomAppBar.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/Progress.dart';
import 'package:ssurade/utils/toast.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  MainProgress _progress = MainProgress.init;

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
      if (setting.uSaintSession.isNotEmpty) {
        if (!await setting.uSaintSession.tryLogin()) {
          showToast("자동로그인을 실패했습니다.");
        } else {
          showToast("자동로그인했습니다.");
        }
      }

      globals.setStateOfMainPage(() {
        _progress = MainProgress.finish;
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
            onAjaxReadyStateChange: (controller, ajax) async {
              globals.webViewXHRTotalCount++;

              if (ajax.readyState == AjaxRequestReadyState.HEADERS_RECEIVED) {
                if (globals.webViewXHRProgress == XHRProgress.ready) {
                  globals.webViewXHRProgress = XHRProgress.running;
                } else if (globals.webViewXHRProgress != XHRProgress.none) {
                  log("ajax error 1");
                }

                globals.webViewXHRRunningCount++;
              }

              if (ajax.readyState == AjaxRequestReadyState.DONE) {
                if (globals.webViewXHRProgress == XHRProgress.running) {
                  globals.webViewXHRProgress = XHRProgress.finish;
                }

                globals.webViewXHRRunningCount--;
              }
            },
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                useShouldInterceptAjaxRequest: true,
                cacheEnabled: false,
                clearCache: true,
              ),
            ),
          ),
        ),
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
                    : ((globals.setting.uSaintSession.isLogin
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
                                globals.setting.uSaintSession.isNotEmpty
                                    ? OutlinedButton(
                                        onPressed: () async {
                                          if (!await globals.setting.uSaintSession.tryLogin()) {
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
