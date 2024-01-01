import 'package:flutter/material.dart';
import 'package:ssurade/components/custom_app_bar.dart';
import 'package:ssurade/crawling/common/crawler.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/utils/toast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController idController = TextEditingController(), pwController = TextEditingController();
  bool lockLoginButton = false;

  @override
  void initState() {
    super.initState();

    idController.text = Crawler.loginSession().id;
    pwController.text = Crawler.loginSession().password;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("로그인"),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: AutofillGroup(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: TextFormField(
                    decoration: const InputDecoration(hintText: "유세인트 아이디(학번)를 입력하세요."),
                    controller: idController,
                    autofillHints: const [AutofillHints.username],
                  ),
                ),
                Flexible(
                  child: TextFormField(
                    decoration: const InputDecoration(hintText: "유세인트 비밀번호를 입력하세요."),
                    controller: pwController,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (lockLoginButton) return;
                    setState(() {
                      lockLoginButton = true;
                    });

                    var session = Crawler.loginSession();
                    session.id = idController.text;
                    session.password = pwController.text;

                    if (await session.execute().catchError((_) => false)) {
                      if (mounted) Navigator.pop(context);
                      showToast("로그인 했어요.");

                      globals.analytics.logEvent(name: "login", parameters: {"auto_login": "false"});
                    } else {
                      session.logout();
                    }
                    session.saveFile();

                    setState(() {
                      lockLoginButton = false;
                    });
                  },
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                  ),
                  child: Text(lockLoginButton ? "로그인하는 중..." : "로그인"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
