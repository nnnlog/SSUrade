library ssurade.globals;

import 'package:event/event.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:ssurade/crawling/Crawler.dart';
import 'package:ssurade/filesystem/FileSystem.dart';
import 'package:ssurade/types/Semester.dart';
import 'package:ssurade/types/Setting.dart';
import 'package:ssurade/types/YearSemester.dart';
import 'package:ssurade/types/subject/SemesterSubjectsManager.dart';

bool isLightMode = true; // SchedulerBinding.instance.window.platformBrightness == Brightness.light;

late Setting setting;
late SemesterSubjectsManager semesterSubjectsManager;

late FirebaseAnalytics analytics;

Event newGradeFoundEvent = Event();

Future<void> init() async {
  await initFileSystem();
  await Future.wait([
    Setting.loadFromFile().then((value) => setting = value),
    Crawler.loginSession().loadFromFile(),
    Future(() async {
      semesterSubjectsManager = await SemesterSubjectsManager.loadFromFile();
      semesterSubjectsManager.data.remove(YearSemester(2022, Semester.second));
      await semesterSubjectsManager.initAllPassFailSubject();
    }),
  ]);
}
