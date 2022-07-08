import 'package:flutter/material.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/views/Grade.dart';
import 'package:ssurade/views/Information.dart';
import 'package:ssurade/views/Login.dart';
import 'package:ssurade/views/MainPage.dart';
import 'package:ssurade/views/SettingPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '숭실대학교 성적/학점 조회',
      theme: ThemeData(
        primaryColor: const MaterialColor(0xFF00A4CA, {
          50: Color.fromRGBO(0, 164, 202, .1),
          100: Color.fromRGBO(0, 164, 202, .2),
          200: Color.fromRGBO(0, 164, 202, .3),
          300: Color.fromRGBO(0, 164, 202, .4),
          400: Color.fromRGBO(0, 164, 202, .5),
          500: Color.fromRGBO(0, 164, 202, .6),
          600: Color.fromRGBO(0, 164, 202, .7),
          700: Color.fromRGBO(0, 164, 202, .8),
          800: Color.fromRGBO(0, 164, 202, .9),
          900: Color.fromRGBO(0, 164, 202, 1),
        }),
        scaffoldBackgroundColor: globals.isLightMode ? Colors.white : Colors.black54,
        fontFamily: "Pretendard",
      ),
      // darkTheme: ThemeData.dark(), // TODO
      initialRoute: '/',
      routes: {
        '/': (context) => const MainPage(),
        '/login': (context) => const LoginPage(),
        '/view': (context) => const GradePage(),
        '/setting': (context) => const SettingPage(),
        '/information': (context) => const InformationPage(),
      },
    );
  }
}
