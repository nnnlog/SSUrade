import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:ssurade/crawling/common/Crawler.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/subject/Subject.dart';
import 'package:ssurade/utils/notification.dart';
import 'package:workmanager/workmanager.dart';

Future<void> updateBackgroundService() async {
  await unregisterBackgroundService();
  if (globals.setting.noticeGradeInBackground) {
    await registerBackgroundService();
  }
}

Future<void> registerBackgroundService() async {
  await globals.flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  await Workmanager().registerPeriodicTask(
    "ssurade",
    "bg_service",
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresDeviceIdle: false,
    ),
    backoffPolicy: BackoffPolicy.linear,
    existingWorkPolicy: ExistingWorkPolicy.replace,
  );
}

Future<void> unregisterBackgroundService() => Workmanager().cancelByUniqueName("ssurade");

@pragma('vm:entry-point')
void startBackgroundService() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await globals.init();

      var lastSemester = globals.semesterSubjectsManager.data.keys.last;
      var gradeData = (await Crawler.singleGrade(lastSemester).execute())!;

      var originalGradeData = globals.semesterSubjectsManager.data[lastSemester]!;
      List<String> updates = [];

      for (var subject in gradeData.subjects.values) {
        if (subject.grade.isNotEmpty && originalGradeData.subjects[subject.code]?.grade != subject.grade) {
          updates.add("[${subject.name}] : ${subject.grade}");
        }
      }

      if (gradeData.semesterRanking.isNotEmpty && originalGradeData.semesterRanking.isEmpty) {
        updates.add("[학기 석차] > ${gradeData.semesterRanking}");
        updates.add("[전체 석차] > ${gradeData.totalRanking}");
      }

      if (updates.isNotEmpty) {
        showNotification("성적 정보 변동", updates.join("\n"));
      } else if (kDebugMode) {
        showNotification("not updated", gradeData.subjects.values.map((e) => "${e.name} : ${e.grade}").join("\n"));
      }
    } catch (err) {
      Logger().e(err.toString());
      throw Exception(err);
    }
    return true;
  });
}
