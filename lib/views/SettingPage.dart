import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ssurade/components/CustomAppBar.dart';
import 'package:ssurade/crawling/background/BackgroundService.dart';
import 'package:ssurade/crawling/common/Crawler.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/utils/toast.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _refreshGrade = false;
  final TextEditingController _timeoutGradeController = TextEditingController(), _timeoutAllGradeController = TextEditingController();

  void _proxySetState(_) {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

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
                    title: const Text("성적 변경 알림 (백그라운드)"),
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
                      showToast("설정을 변경했습니다.");
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
                      showToast("설정을 변경했습니다.");
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

                            showToast("성적 정보 동기화를 시작합니다.");

                            var res = await Crawler.allGrade().execute();
                            if (res == null) {
                              showToast("성적 정보를 가져오지 못했습니다.\n다시 시도해주세요.");
                              return;
                            }

                            globals.semesterSubjectsManager = res;
                            globals.semesterSubjectsManager.saveFile(); // saving file does not need await
                            _refreshGrade = false;
                            showToast("성적 정보를 동기화했습니다.");
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                          child: const Text("전체 학기 성적 동기화"),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            globals.semesterSubjectsManager.data.clear();
                            globals.semesterSubjectsManager.saveFile();
                            showToast("저장된 성적 정보를 삭제했습니다.");
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                          child: const Text("성적 정보 삭제"),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            Crawler.loginSession().logout();
                            Crawler.loginSession().saveFile();

                            globals.semesterSubjectsManager.data.clear();
                            globals.semesterSubjectsManager.saveFile();

                            showToast("로그아웃했습니다.");
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
