import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:ssurade/crawling/common/Crawler.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/utils/notification.dart';
import 'package:ssurade/utils/toast.dart';
import 'package:workmanager/workmanager.dart';

Future<void> disableBatteryOptimize({bool show = false}) async {
  bool? isAlreadyEnabled = await DisableBatteryOptimization.isBatteryOptimizationDisabled;
  if (isAlreadyEnabled == true) {
    if (show) showToast("이미 배터리 최적화 대상에서 제외되어 있어요.");
    return;
  }
  bool? ok = await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
  if (!show) return;
  if (ok == true) {
    showToast("배터리 최적화에서 제외되었어요.");
  } else {
    showToast("배터리 최적화가 켜져 있으면 성적 확인이 지연될 수 있어요.");
  }
}

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
          updates.add("${subject.name} > ${subject.grade}");
          originalGradeData.subjects[subject.code]!.grade = subject.grade;
        }
      }

      if (gradeData.semesterRanking.isNotEmpty && originalGradeData.semesterRanking.isEmpty) {
        updates.add("[학기 석차] > ${gradeData.semesterRanking}");
        updates.add("[전체 석차] > ${gradeData.totalRanking}");
      }

      if (updates.isNotEmpty) {
        await showNotification("성적 정보 변경", updates.join("\n"));
        await globals.semesterSubjectsManager.saveFile();
      } else if (kDebugMode) {
        await showNotification("not updated (${DateTime.now().toString()})", gradeData.subjects.values.map((e) => "${e.name} : ${e.grade}").join("\n"));
      }
    } catch (err) {
      Logger().e(err.toString());
      throw Exception(err);
    }
    return true;
  });
}
