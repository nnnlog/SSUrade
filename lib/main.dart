import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/background/background_service.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/views/absent_page.dart';
import 'package:ssurade/views/category_statistics_page.dart';
import 'package:ssurade/views/chapel_page.dart';
import 'package:ssurade/views/grade_page.dart';
import 'package:ssurade/views/grade_statistics_page.dart';
import 'package:ssurade/views/information.dart';
import 'package:ssurade/views/login.dart';
import 'package:ssurade/views/main_page.dart';
import 'package:ssurade/views/scholarship_page.dart';
import 'package:ssurade/views/setting_page.dart';
import 'package:workmanager/workmanager.dart';

import 'firebase_options.dart';

void main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://71fdb674566745408a9611f2e72b2599@o4504542772789248.ingest.sentry.io/4504551497596928';
      options.tracesSampleRate = 0.1;
    },
    appRunner: () async {
      if (Platform.isAndroid) {
        await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
      }

      Workmanager().initialize(startBackgroundService, isInDebugMode: kDebugMode);

      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      globals.analytics = FirebaseAnalytics.instance;

      runApp(const MyApp());
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '숭실대학교 성적 조회',
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
        '/grade_view': (context) => const GradePage(),
        '/grade_statistics': (context) => const GradeStatisticsPage(),
        '/category_statistics': (context) => const StatisticsPage(),
        '/chapel': (context) => const ChapelPage(),
        '/scholarship': (context) => const ScholarshipPage(),
        '/absent': (context) => const AbsentPage(),
        '/setting': (context) => const SettingPage(),
        '/information': (context) => const InformationPage(),
      },
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: globals.analytics),
        SentryNavigatorObserver(),
      ],
    );
  }
}
