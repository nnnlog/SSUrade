library ssurade.globals;

import 'package:event/event.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ssurade/crawling/common/Crawler.dart';
import 'package:ssurade/crawling/common/WebViewWorker.dart';
import 'package:ssurade/filesystem/FileSystem.dart';
import 'package:ssurade/types/BackgroundSetting.dart';
import 'package:ssurade/types/Setting.dart';
import 'package:ssurade/types/subject/SemesterSubjectsManager.dart';

bool isLightMode = true; // SchedulerBinding.instance.window.platformBrightness == Brightness.light;
bool isBackground = false;

late Setting setting;
late BackgroundSetting bgSetting;
late SemesterSubjectsManager semesterSubjectsManager;

late FirebaseAnalytics analytics;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
AndroidNotificationChannel channel = const AndroidNotificationChannel(
  "ssurade",
  "notice",
  importance: Importance.high,
  showBadge: true,
);

Event newGradeFoundEvent = Event();
List<String> assets = ["common.js"];

Future<void> init() async {
  await initFileSystem();
  await Future.wait([
    Setting.loadFromFile().then((value) => setting = value),
    BackgroundSetting.loadFromFile().then((value) => bgSetting = value),
    Crawler.loginSession().loadFromFile(),
    SemesterSubjectsManager.loadFromFile().then((value) => semesterSubjectsManager = value),
    ...assets.map((e) => rootBundle.loadString("assets/js/$e").then((value) {
          WebViewWorker.webViewScript.add(value);
        })),
  ]);

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (NotificationResponse r) => Future.value());
}
