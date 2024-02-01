import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:ssurade/crawling/common/crawler.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/chapel/chapel_attendance.dart';
import 'package:ssurade/types/semester/semester.dart';
import 'package:ssurade/types/semester/year_semester.dart';
import 'package:ssurade/utils/notification.dart';
import 'package:ssurade/utils/set.dart';
import 'package:ssurade/utils/toast.dart';
import 'package:workmanager/workmanager.dart';

Future<void> disableBatteryOptimize({bool show = false}) async {
  bool? isAlreadyEnabled = await DisableBatteryOptimization.isBatteryOptimizationDisabled;
  if (isAlreadyEnabled == true) {
    if (show) showToast("이미 배터리 최적화 대상에서 제외되어 있어요.");
    return;
  }
  /*bool? ok = */
  await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
  // if (!show) return;
  // if (ok == true) {
  //   showToast("배터리 최적화에서 제외되었어요.");
  // } else {
  //   showToast("배터리 최적화가 켜져 있으면 성적 확인이 지연될 수 있어요.");
  // }
}

Future<void> updateBackgroundService({lazy = false}) async {
  await unregisterBackgroundService();
  if (globals.setting.noticeGradeInBackground) {
    await registerBackgroundService(lazy: lazy);
  }
}

Future<void> registerBackgroundService({lazy = false}) async {
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
    initialDelay: lazy ? Duration(minutes: globals.setting.interval) : Duration.zero,
  );
}

Future<void> unregisterBackgroundService() => Workmanager().cancelByUniqueName("ssurade");

Future<void> fetchGrade() async {
  if (globals.semesterSubjectsManager.isEmpty) return;

  var lastSemester = globals.semesterSubjectsManager.data.keys.last;
  var gradeData = await Crawler.singleGradeBySemester(lastSemester).execute();

  var originalGradeData = globals.semesterSubjectsManager.data[lastSemester]!;
  List<String> updates = [];

  for (var subject in gradeData.subjects.values) {
    if (subject.grade.isNotEmpty && originalGradeData.subjects[subject.code]?.grade != subject.grade) {
      if (globals.setting.showGrade) {
        updates.add("${subject.name} > ${subject.grade}");
      } else {
        updates.add(subject.name);
      }
      originalGradeData.subjects[subject.code]!.grade = subject.grade;
    }
  }

  if (gradeData.semesterRanking.isNotEmpty && originalGradeData.semesterRanking.isEmpty) {
    if (globals.setting.showGrade) {
      updates.add("[학기 석차] > ${gradeData.semesterRanking.display}");
      updates.add("[전체 석차] > ${gradeData.totalRanking.display}");
    } else {
      updates.add("[학기 석차]");
      updates.add("[전체 석차]");
    }
    originalGradeData.semesterRanking = gradeData.semesterRanking;
    originalGradeData.totalRanking = gradeData.totalRanking;
  }

  if (updates.isNotEmpty) {
    await showNotification("성적 정보 변경", updates.join(globals.setting.showGrade ? "\n" : ", "));
    await globals.semesterSubjectsManager.saveFile();
  } else if (kDebugMode) {
    await showNotification("not updated (${DateTime.now().toString()})", gradeData.subjects.values.map((e) => "${e.name} : ${e.grade}").join("\n"));
  }
}

Future<void> fetchChapel() async {
  if (globals.chapelInformationManager.isEmpty) return;

  var lastSemester = globals.chapelInformationManager.data.last.currentSemester;
  var chapelData = await Crawler.singleChapelBySemester(lastSemester).execute();

  var originalAttendanceData = globals.chapelInformationManager.data[lastSemester]!;
  List<String> updates = [];

  for (var data in chapelData.attendances) {
    if (data.attendance != ChapelAttendance.unknown && originalAttendanceData.attendances[data.lectureDate]?.attendance != data.attendance) {
      updates.add("${data.lectureDate} > ${data.attendance.display}");
      originalAttendanceData.attendances.remove(data);
      originalAttendanceData.attendances.add(data);
    }
  }

  if (updates.isNotEmpty) {
    await showNotification("채플 출결 변경", updates.join("\n"));
    await globals.chapelInformationManager.saveFile();
  } else if (kDebugMode) {
    await showNotification("not updated (${DateTime.now().toString()})", chapelData.attendances.map((e) => "${e.lectureDate} : ${e.attendance.display}").join("\n"));
  }
}

Future<void> fetchNewChapel() async {
  List<YearSemester> search = [];

  int year = DateTime.now().year;
  search.add(YearSemester(year, Semester.first));
  search.add(YearSemester(year, Semester.second));

  var chapelData = await Crawler.allChapel(search).execute();
  List<String> updates = [];

  for (var data in chapelData.data) {
    if (!globals.chapelInformationManager.data.contains(data)) {
      updates.add(data.currentSemester.display);
      globals.chapelInformationManager.data.add(data);
    }
  }

  if (updates.isNotEmpty) {
    await showNotification("채플 정보 등록", updates.join("\n"));
    await globals.chapelInformationManager.saveFile();
  } else if (kDebugMode) {
    await showNotification("not updated (${DateTime.now().toString()})", globals.chapelInformationManager.data.map((e) => "${e.currentSemester.display}").join("\n"));
  }
}

Future<void> fetchScholarship() async {
  var scholarshipData = await Crawler.getScholarship().execute();

  var originalData = globals.scholarshipManager.data;
  List<String> updates = [];

  int index = 0;
  for (var data in scholarshipData.data) {
    int prev = index;
    while (index < originalData.length && data.name != originalData[index].name) {
      index++;
    }
    bool updated = false;
    if (index < originalData.length) {
      if (data.when != originalData[index].when || data.process != originalData[index].process) {
        updated = true;
      }
    } else {
      updated = true;
      index = prev;
    }

    if (updated) {
      updates.add("${data.name} > ${data.process} (${data.price}원)");
    }
  }

  if (updates.isNotEmpty) {
    if (originalData.isNotEmpty) {
      await showNotification("장학 정보 변경", updates.join("\n"));
    }
    globals.scholarshipManager = scholarshipData;
    await globals.scholarshipManager.saveFile();
  } else if (kDebugMode) {
    await showNotification("not updated (${DateTime.now().toString()})", scholarshipData.data.map((e) => "${e.name} : ${e.when.display}").join("\n"));
  }
}

@pragma('vm:entry-point')
void startBackgroundService() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await globals.init();
      Crawler.loginSession().isBackground = true;

      var futures = [
        fetchGrade(),
        fetchChapel(),
        fetchNewChapel(),
        fetchScholarship(),
      ];

      await Future.wait(futures).catchError((e) => throw e);
    } catch (err, st) {
      Logger().e(err, stackTrace: st);
      throw Exception(err);
    }
    return true;
  });
}
