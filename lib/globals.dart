library ssurade.globals;

import 'package:event/event.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import 'package:ssurade/crawling/common/Crawler.dart';
import 'package:ssurade/crawling/common/WebViewWorker.dart';
import 'package:ssurade/filesystem/FileSystem.dart';
import 'package:ssurade/types/Setting.dart';
import 'package:ssurade/types/subject/SemesterSubjectsManager.dart';

bool isLightMode = true; // SchedulerBinding.instance.window.platformBrightness == Brightness.light;

late Setting setting;
late SemesterSubjectsManager semesterSubjectsManager;

late FirebaseAnalytics analytics;

Event newGradeFoundEvent = Event();
List<String> assets = ["common.js"];

Future<void> init() async {
  await initFileSystem();
  await Future.wait([
    Setting.loadFromFile().then((value) => setting = value),
    Crawler.loginSession().loadFromFile(),
    SemesterSubjectsManager.loadFromFile().then((value) => semesterSubjectsManager = value),
    ...assets.map((e) => rootBundle.loadString("assets/js/$e").then((value) {
          WebViewWorker.webViewScript.add(value);
        })),
  ]);
}
