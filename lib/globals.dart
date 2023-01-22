library ssurade.globals;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:ssurade/crawling/Crawler.dart';
import 'package:ssurade/filesystem/FileSystem.dart';
import 'package:ssurade/types/Setting.dart';
import 'package:ssurade/types/subject/SemesterSubjectsManager.dart';

late Setting setting;
late SemesterSubjectsManager semesterSubjectsManager;

bool isLightMode = true; // SchedulerBinding.instance.window.platformBrightness == Brightness.light;

late FirebaseAnalytics analytics;

Future<void> init() async {
  await initFileSystem();
  await Future.wait([
    Setting.loadFromFile().then((value) => setting = value),
    Crawler.loginSession().loadFromFile(),
    Future(() async {
      semesterSubjectsManager = await SemesterSubjectsManager.loadFromFile();
      await semesterSubjectsManager.initAllPassFailSubject();
    }),
  ]);
}
