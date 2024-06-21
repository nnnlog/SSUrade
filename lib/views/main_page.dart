import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ssurade/components/common/custom_app_bar.dart';
import 'package:ssurade/components/common/show_scrollabe_dialog.dart';
import 'package:ssurade/crawling/background/background_service.dart';
import 'package:ssurade/crawling/common/crawler.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/etc/progress.dart';
import 'package:ssurade/types/semester/semester.dart';
import 'package:ssurade/types/semester/year_semester.dart';
import 'package:ssurade/types/subject/ranking.dart';
import 'package:ssurade/types/subject/semester_subjects_manager.dart';
import 'package:ssurade/utils/set.dart';
import 'package:ssurade/utils/toast.dart';
import 'package:ssurade/utils/update.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final Completer<void> _agreeFuture = Completer();
  late String _agreement, _agreement_short;
  MainProgress _progress = MainProgress.init;

  void handleLoginStatusChange(_) {
    setState(() {});
  }

  void handleLoginFail(msg) {
    // showToast("로그인을 실패했어요.");
    // showToast("메인 화면에서 자동 로그인을 다시 시도하거나 새로운 계정으로 로그인하세요.");

    if (msg != null) {
      showToast(msg.value);
    }

    globals.analytics.logEvent(name: "login_fail");
  }

  @override
  void dispose() {
    super.dispose();

    Crawler.loginSession().loginStatusChangeEvent.unsubscribe(handleLoginStatusChange);
    Crawler.loginSession().loginFailEvent.unsubscribe(handleLoginFail);
  }

  @override
  void initState() {
    super.initState();

    Crawler.loginSession().loginStatusChangeEvent.subscribe(handleLoginStatusChange);
    Crawler.loginSession().loginFailEvent.subscribe(handleLoginFail);

    (() async {
      await globals.init();

      if (!globals.setting.agree) {
        await disableBatteryOptimize(show: true);

        _agreement = await rootBundle.loadString("assets/agreement.txt");
        _agreement_short = await rootBundle.loadString("assets/agreement_short.txt");
        setState(() {
          _progress = MainProgress.agree;
        });
        await _agreeFuture.future;
      } else {
        await disableBatteryOptimize();
      }

      updateBackgroundService(lazy: true); // repair background service

      await globals.flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
      await globals.flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(globals.channel);

      Crawler.loginSession().loginStatusChangeEvent.subscribe((args) {
        updateBackgroundService(lazy: true);
      });

      setState(() {
        _progress = MainProgress.finish;
      });

      if (Crawler.loginSession().isNotEmpty) {
        Crawler.loginSession().execute().then((value) {
          if (value) {
            showToast("자동으로 로그인 했어요.");

            globals.analytics.logEvent(name: "login", parameters: {"auto_login": "true"});
          } else {
            showToast("자동 로그인을 실패했어요.");
          }
        });

        Crawler.gradeSemesterList().execute().then((value) async {
          int year = DateTime.now().year;
          if (DateTime.now().month <= 2) year--;
          for (var e in Semester.values) {
            var key = YearSemester(year, e);
            if (!value.containsKey(key)) {
              value[key] = const Tuple2(Ranking.unknown, Ranking.unknown);
            }
          }

          var manager = globals.semesterSubjectsManager;
          Map<YearSemester, Tuple2<Ranking, Ranking>> newSemesters = {};

          for (var semester in value.keys) {
            if (!manager.data.containsKey(semester)) {
              newSemesters[semester] = value[semester]!;
            }
          }

          if (newSemesters.isNotEmpty) {
            List<Future<SemesterSubjectsManager>> wait = [];

            wait.add(Crawler.allGradeByCategory().execute());
            wait.add(Crawler.allGradeBySemester(map: newSemesters).execute());

            var ret = (await Future.wait(wait))..removeWhere((element) => element.isEmpty);
            var result = SemesterSubjectsManager.merges(ret);
            if (result == null) return;

            for (var semester in newSemesters.keys) {
              globals.semesterSubjectsManager.data[semester] = result.data[semester]!;
            }

            globals.semesterSubjectsManager.saveFile();
          }
        });

        {
          int year = DateTime.now().year;
          if (DateTime.now().month <= 2) year--;
          List<YearSemester> searches = [];
          for (var e in [Semester.first, Semester.second]) {
            var key = YearSemester(year, e);
            if (globals.chapelInformationManager.data[key] != null) {
              searches.add(key);
            }
          }

          Crawler.allChapel(searches).execute().then((value) {
            if (value.isEmpty) return;

            for (var data in value.data) {
              globals.chapelInformationManager.data.add(data);
            }

            globals.chapelInformationManager.saveFile();
          });
        }

        // Crawler.allGrade().execute().then((value) {
        //   if (value.isEmpty) return;
        //   if (value.state != STATE_FULL) return;
        //
        //   bool foundNewSemester = false;
        //   List<String> newSemester = [];
        //
        //   for (var key in value.data.keys) {
        //     if (!globals.semesterSubjectsManager.data.containsKey(key)) {
        //       foundNewSemester = true;
        //       newSemester.add("${key.year}학년도 ${key.semester.name}");
        //
        //       Crawler.semesterSubjectDetailGrade(value.data[key]!).execute().then((value) {
        //         for (var subjectCode in value.keys) {
        //           if (value[subjectCode]?.isNotEmpty == true) {
        //             globals.semesterSubjectsManager.data[key]?.subjects[subjectCode]?.detail = value[subjectCode]!;
        //             globals.semesterSubjectsManager.saveFile();
        //
        //             globals.gradeUpdateEvent.broadcast();
        //           }
        //         }
        //       });
        //     }
        //   }
        //
        //   globals.semesterSubjectsManager = SemesterSubjectsManager.merge(value, globals.semesterSubjectsManager)!;
        //   globals.semesterSubjectsManager.saveFile();
        //
        //   globals.gradeUpdateEvent.broadcast();
        //
        //   if (foundNewSemester) {
        //     showToast("새로운 학기(${newSemester.join(", ")}) 성적을 찾았어요.");
        //     globals.gradeUpdateEvent.broadcast();
        //   }
        // });

        // {
        //   var value = globals.semesterSubjectsManager;
        //   for (var key in value.data.keys) {
        //     Crawler.semesterSubjectDetailGrade(value.data[key]!).execute().then((value) {
        //       for (var subjectCode in value.keys) {
        //         if (value[subjectCode]?.isNotEmpty == true) {
        //           globals.semesterSubjectsManager.data[key]?.subjects[subjectCode]?.detail = value[subjectCode]!;
        //           globals.gradeUpdateEvent.broadcast();
        //           globals.semesterSubjectsManager.saveFile();
        //         }
        //       }
        //     });
        //   }
        // }
      }

      fetchAppVersion().then((value) {
        if (value.item2 != "") {
          showToast("새로운 버전 v${value.item2}(으)로 업데이트할 수 있어요.");
          showToast("Github 또는 Play Store에 방문해 주세요.");
        }
      });
    })();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: customAppBar("숭실대학교 학사 정보 조회"),
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
                                      showScrollableDialog(
                                        context,
                                        [
                                          SingleChildScrollView(
                                            child: SelectableText(_agreement),
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
                        : [
                            SingleChildScrollView(
                              child: Column(
                                children: <Widget>[
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
                                        visible: Crawler.loginSession().isNotEmpty,
                                        child: OutlinedButton(
                                          onPressed: () async {
                                            Navigator.pushNamed(context, "/grade_statistics");
                                          },
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: const Size.fromHeight(40),
                                          ),
                                          child: const Text("성적 통계"),
                                        ),
                                      ),
                                      Visibility(
                                        visible: Crawler.loginSession().isNotEmpty,
                                        child: OutlinedButton(
                                          onPressed: () async {
                                            Navigator.pushNamed(context, "/category_statistics");
                                          },
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: const Size.fromHeight(40),
                                          ),
                                          child: const Text("이수 구분별 성적 통계"),
                                        ),
                                      ),
                                      Visibility(
                                        visible: Crawler.loginSession().isNotEmpty,
                                        child: OutlinedButton(
                                          onPressed: () async {
                                            Navigator.pushNamed(context, "/chapel");
                                          },
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: const Size.fromHeight(40),
                                          ),
                                          child: const Text("채플 정보 조회"),
                                        ),
                                      ),
                                      Visibility(
                                        visible: Crawler.loginSession().isNotEmpty,
                                        child: OutlinedButton(
                                          onPressed: () async {
                                            Navigator.pushNamed(context, "/scholarship");
                                          },
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: const Size.fromHeight(40),
                                          ),
                                          child: const Text("장학 정보 조회"),
                                        ),
                                      ),
                                      Visibility(
                                        visible: Crawler.loginSession().isNotEmpty,
                                        child: OutlinedButton(
                                          onPressed: () async {
                                            Navigator.pushNamed(context, "/absent");
                                          },
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: const Size.fromHeight(40),
                                          ),
                                          child: const Text("유고 결석 정보 조회"),
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
                                              showToast("자동으로 로그인 했어요.");
                                            } else {
                                              showToast("자동 로그인을 실패했어요.");
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
                                      OutlinedButton(
                                        onPressed: () => launchUrl(
                                          Uri.parse("https://github.com/nnnlog/SSUrade/blob/master/USAGE.md"),
                                          mode: LaunchMode.externalApplication,
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size.fromHeight(40),
                                        ),
                                        child: const Text(
                                          "사용법 및 도움말",
                                        ),
                                      ),
                                    ],
                              ),
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
