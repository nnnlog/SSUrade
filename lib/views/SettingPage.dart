import 'package:flutter/material.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/utils/toast.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _refreshGrade = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("설정", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: Colors.white,
        shadowColor: const Color.fromRGBO(0, 0, 0, 0),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
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
                    title: const Text("마지막 학기 성적 자동 동기화"),
                  ),
                ] +
                (globals.setting.saintSession.isLogin
                    ? <Widget>[
                        OutlinedButton(
                          onPressed: () async {
                            if (_refreshGrade) return;
                            _refreshGrade = true;

                            showToast("성적 정보 동기화를 시작합니다.");

                            var res = await globals.setting.saintSession.getAllGrade();
                            if (res == null) {
                              showToast("성적 정보를 가져오지 못했습니다.\n다시 시도해주세요.");
                              return;
                            }

                            globals.subjectDataCache.data = res;
                            globals.subjectDataCache.saveFile();
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
                            globals.subjectDataCache.data = {};
                            globals.subjectDataCache.saveFile();
                            showToast("저장된 성적 정보를 삭제했습니다.");
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                          child: const Text("성적 정보 삭제"),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              globals.setting.saintSession.logout();
                              globals.setting.saveFile();
                              globals.subjectDataCache.data = {};
                              globals.subjectDataCache.saveFile();
                              globals.setStateOfMainPage(() {});

                              showToast("로그아웃했습니다.");
                            });
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
