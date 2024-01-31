library ssurade.globals;

import 'package:event/event.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ssurade/crawling/common/crawler.dart';
import 'package:ssurade/crawling/common/webview_worker.dart';
import 'package:ssurade/filesystem/filesystem.dart';
import 'package:ssurade/types/chapel/chapel_information_manager.dart';
import 'package:ssurade/types/scholarship/scholarship_manager.dart';
import 'package:ssurade/types/setting/background_setting.dart';
import 'package:ssurade/types/setting/setting.dart';
import 'package:ssurade/types/subject/semester_subjects_manager.dart';

bool isLightMode = true; // SchedulerBinding.instance.window.platformBrightness == Brightness.light;
bool isBackground = false;

late Setting setting;
late BackgroundSetting bgSetting;
late SemesterSubjectsManager semesterSubjectsManager;
late ChapelInformationManager chapelInformationManager;
late ScholarshipManager scholarshipManager;

late FirebaseAnalytics analytics;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
AndroidNotificationChannel channel = const AndroidNotificationChannel(
  "ssurade",
  "notice",
  importance: Importance.high,
  showBadge: true,
);

Event gradeUpdateEvent = Event();
List<String> assets = ["common.js"];

Future<void> init() async {
  await initFileSystem();
  await Future.wait([
    Setting.loadFromFile().then((value) => setting = value),
    BackgroundSetting.loadFromFile().then((value) => bgSetting = value),
    Crawler.loginSession().loadFromFile(),
    SemesterSubjectsManager.loadFromFile().then((value) => semesterSubjectsManager = value),
    ChapelInformationManager.loadFromFile().then((value) => chapelInformationManager = value),
    ScholarshipManager.loadFromFile().then((value) => scholarshipManager = value),
    ...assets.map((e) => rootBundle.loadString("assets/js/$e").then((value) {
          WebViewWorker.webViewScript.add(value);
        })),
  ]);

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (NotificationResponse r) => Future.value());
}
