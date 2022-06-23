import 'package:flutter/material.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/utils/toast.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
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
            children: globals.setting.saintSession.isLogin
                ? [
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          globals.setting.saintSession.logout();
                          globals.setting.saveFile();
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
                : const [
                    Text("기능 추가 예정입니다."),
                  ],
          ),
        ),
      ),
    );
  }
}
