import 'package:flutter/material.dart';
import 'package:ssurade/components/CustomAppBar.dart';
import 'package:ssurade/crawling/USaintSession.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/utils/toast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController numberController = TextEditingController(), pwController = TextEditingController();
  bool lockLoginButton = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("로그인"),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: TextFormField(
                  decoration: const InputDecoration(hintText: "유세인트 아이디(학번)을 입력하세요."),
                  controller: numberController,
                ),
              ),
              Flexible(
                child: TextFormField(
                  decoration: const InputDecoration(hintText: "유세인트 비밀번호를 입력하세요."),
                  controller: pwController,
                  obscureText: true,
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (lockLoginButton) return;
                  lockLoginButton = true;

                  var temp = USaintSession(numberController.text, pwController.text);
                  if (await temp.tryLogin(refresh: true)) {
                    globals.setting.uSaintSession = temp;
                    globals.setting.saveFile();

                    Navigator.pop(context);
                    globals.setStateOfMainPage(() {});
                    showToast("로그인했습니다.");
                  } else {
                    showToast("로그인을 실패했습니다.\n정보를 확인하고 다시 시도해주세요.");
                  }

                  lockLoginButton = false;
                },
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
                child: const Text("로그인"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
