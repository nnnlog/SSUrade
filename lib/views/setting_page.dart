import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ssurade/components/custom_app_bar.dart';
import 'package:ssurade/crawling/background/background_service.dart';
import 'package:ssurade/crawling/common/crawler.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/subject/semester_subjects_manager.dart';
import 'package:ssurade/types/subject/state.dart';
import 'package:ssurade/utils/toast.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _refreshGrade = false;
  bool _refreshGradeDetail = false;
  final TextEditingController _intervalController = TextEditingController(), _timeoutGradeController = TextEditingController(), _timeoutAllGradeController = TextEditingController();

  void _proxySetState(_) {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _intervalController.text = globals.setting.interval.toString();
    _timeoutGradeController.text = globals.setting.timeoutGrade.toString();
    _timeoutAllGradeController.text = globals.setting.timeoutAllGrade.toString();

    Crawler.loginSession().loginStatusChangeEvent.subscribe(_proxySetState);
  }

  @override
  void dispose() {
    super.dispose();

    Crawler.loginSession().loginStatusChangeEvent.unsubscribe(_proxySetState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("설정"),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
                  SwitchListTile(
                    value: globals.setting.refreshGradeAutomatically,
                    onChanged: (value) {
                      setState(() {
                        globals.setting.refreshGradeAutomatically = value;
                      });

                      globals.setting.saveFile();
                    },
                    title: const Text("마지막 학기 성적 자동으로 불러오기"),
                  ),
                  SwitchListTile(
                    value: globals.setting.noticeGradeInBackground,
                    onChanged: (value) {
                      if (value) {
                        disableBatteryOptimize();
                      }
                      setState(() {
                        globals.setting.noticeGradeInBackground = value;
                      });

                      globals.setting.saveFile();
                      updateBackgroundService();
                    },
                    title: const Text("성적/채플 변경 알림 (백그라운드)"),
                  ),
                  SwitchListTile(
                    value: globals.setting.showGrade,
                    onChanged: (value) {
                      setState(() {
                        globals.setting.showGrade = value;
                      });

                      globals.setting.saveFile();
                    },
                    title: const Text("성적/채플 변경 알림 - 성적 보이기"),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      disableBatteryOptimize(show: true);
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                    ),
                    child: const Text("배터리 최적화 제외하기"),
                  ),
                  TextField(
                    controller: _intervalController,
                    decoration: const InputDecoration(labelText: "성적/채플 변경 알림 - 확인 주기 (최솟값 : 15분)"),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onEditingComplete: () {
                      var temp = int.parse(_intervalController.text);
                      if (temp < 1) {
                        showToast("올바른 값을 입력하세요.");
                        _intervalController.text = "15";
                        return;
                      }
                      globals.setting.interval = temp;
                      globals.setting.saveFile();
                      updateBackgroundService(lazy: true);
                      showToast("설정을 변경했어요.");
                    },
                  ),
                  TextField(
                    controller: _timeoutGradeController,
                    decoration: const InputDecoration(labelText: "단일 성적 로딩 시간 제한 (기본값 : 20초)"),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onEditingComplete: () {
                      var temp = int.parse(_timeoutGradeController.text);
                      if (temp < 1) {
                        showToast("올바른 값을 입력하세요.");
                        _timeoutGradeController.text = "20";
                        return;
                      }
                      globals.setting.timeoutGrade = temp;
                      globals.setting.saveFile();
                      showToast("설정을 변경했어요.");
                    },
                  ),
                  TextField(
                    controller: _timeoutAllGradeController,
                    decoration: const InputDecoration(labelText: "전체 성적 로딩 시간 제한 (기본값 : 60초)"),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onEditingComplete: () {
                      var temp = int.parse(_timeoutAllGradeController.text);
                      if (temp < 1) {
                        showToast("올바른 값을 입력하세요.");
                        _timeoutAllGradeController.text = "60";
                        return;
                      }
                      globals.setting.timeoutAllGrade = temp;
                      globals.setting.saveFile();
                      showToast("설정을 변경했어요.");
                    },
                  ),
                  const SizedBox(
                    height: 10,
                    width: 1,
                  ),
                ] +
                (Crawler.loginSession().isLogin
                    ? <Widget>[
                        OutlinedButton(
                          onPressed: () async {
                            if (_refreshGrade) return;
                            _refreshGrade = true;

                            showToast("전체 학기 성적을 불러오는 중이에요...");

                            SemesterSubjectsManager res;
                            try {
                              res = await Crawler.allGrade().execute();
                              if (res.state != STATE_FULL) throw Exception();
                            } catch (_) {
                              showToast("성적 정보를 가져오지 못했어요.\n다시 시도해주세요.");
                              return;
                            }

                            globals.semesterSubjectsManager = res;
                            globals.semesterSubjectsManager.saveFile(); // saving file does not need await
                            _refreshGrade = false;
                            showToast("전체 학기 성적을 불러왔어요.");
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                          child: const Text("전체 학기 성적 불러오기"),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            if (_refreshGradeDetail) return;
                            _refreshGradeDetail = true;

                            showToast("성적 상세 정보를 불러오는 중이에요...");

                            var data = globals.semesterSubjectsManager.data;
                            var futures = <Future>[];
                            for (var key in data.keys) {
                              futures.add(Crawler.semesterSubjectDetailGrade(data[key]!).execute().then((value) {
                                for (var subjectCode in value.keys) {
                                  if (value[subjectCode]?.isNotEmpty == true) {
                                    globals.semesterSubjectsManager.data[key]?.subjects[subjectCode]?.detail = value[subjectCode]!;
                                    globals.semesterSubjectsManager.saveFile();
                                  }
                                }
                              }));
                            }

                            await Future.wait(futures);

                            _refreshGradeDetail = false;
                            showToast("성적 상세 정보를 불러왔어요.");
                            showToast("성적 조회에서 과목을 길게 누르면 상세 성적을 조회할 수 있어요.");
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                          child: const Text("전체 학기 상세 성적 불러오기"),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            globals.semesterSubjectsManager.data.clear();
                            globals.semesterSubjectsManager.saveFile();
                            showToast("저장된 성적 정보를 삭제했어요.");
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                          child: const Text("성적 정보 삭제"),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            globals.chapelInformationManager.data.clear();
                            globals.chapelInformationManager.saveFile();
                            showToast("저장된 채플 정보를 삭제했어요.");
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                          child: const Text("채플 정보 삭제"),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            Crawler.loginSession().logout();
                            Crawler.loginSession().saveFile();

                            globals.semesterSubjectsManager.data.clear();
                            globals.semesterSubjectsManager.saveFile();

                            showToast("로그아웃했어요.");
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                          child: const Text("로그아웃"),
                        ),
                      ]
                    : <Widget>[]),
          ),
        ),
      ),
    );
  }
}
