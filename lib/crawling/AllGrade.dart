import 'dart:collection';
import 'dart:developer';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ssurade/crawling/Crawler.dart';
import 'package:ssurade/crawling/CrawlingTask.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/Semester.dart';
import 'package:ssurade/types/YearSemester.dart';
import 'package:ssurade/types/subject/SemesterSubjectsManager.dart';

class AllGrade extends CrawlingTask<SemesterSubjectsManager?> {
  static final AllGrade _instance = AllGrade._();

  static AllGrade get() {
    return _instance;
  }

  AllGrade._();

  static AllGrade instance = AllGrade._();

  Future<SemesterSubjectsManager?> directExecute(InAppWebViewController controller) async {
    bool isFinished = false;

    SemesterSubjectsManager? result;
    try {
      result = await Future.any([
        Future(() async {
          if (!await Crawler.loginSession().directExecute(controller)) {
            return null;
          }

          result = SemesterSubjectsManager(SplayTreeMap.from({}));

          var year = (await Crawler.entranceGraduateYear().directExecute(controller))!;
          int entranceYear = int.parse(year.item1);
          int graduateYear;
          if (year.item2 == "0000") {
            graduateYear = DateTime.now().year; // 재학 중
          } else {
            graduateYear = int.parse(year.item2) + 1; // 유세인트 오류?
          }

          for (var i = entranceYear; i <= graduateYear; i++) {
            for (var semester in Semester.values) {
              if (isFinished) return null;
              YearSemester key = YearSemester(i, semester);
              result!.data[key] = (await Crawler.singleGrade(
                key,
                reloadPage: false,
              ).directExecute(controller))!;

              if (result!.data[key]?.subjects.isEmpty == true) {
                result!.data.remove(key);
              }
            }
          }

          return result;
        }),
        Future.delayed(Duration(seconds: globals.setting.timeoutAllGrade), () => null),
      ]);
    } catch (e, stacktrace) {
      log(e.toString());
      log(stacktrace.toString());

      return null;
    } finally {
      isFinished = true;
    }

    return result;
  }
}
