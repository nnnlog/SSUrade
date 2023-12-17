import 'dart:collection';
import 'dart:developer';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/Crawler.dart';
import 'package:ssurade/crawling/common/CrawlingTask.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/Semester.dart';
import 'package:ssurade/types/YearSemester.dart';
import 'package:ssurade/types/subject/SemesterSubjectsManager.dart';

class AllGradeBySemester extends CrawlingTask<SemesterSubjectsManager?> {
  int _startYear;

  factory AllGradeBySemester.get({
    int startYear = 0,
    ISentrySpan? parentTransaction,
  }) =>
      AllGradeBySemester._(startYear, parentTransaction);

  AllGradeBySemester._(this._startYear, ISentrySpan? parentTransaction) : super(parentTransaction);

  @override
  String task_id = "all_grade_by_semester";

  @override
  Future<SemesterSubjectsManager?> internalExecute(InAppWebViewController controller) async {
    bool isFinished = false;

    final transaction = parentTransaction == null ? Sentry.startTransaction('AllGradeBySemester', task_id) : parentTransaction!.startChild(task_id);

    SemesterSubjectsManager? result;
    try {
      result = await Future.any([
        Future(() async {
          if (!(await Crawler.loginSession(parentTransaction: transaction).directExecute(controller))) {
            return null;
          }

          result = SemesterSubjectsManager(SplayTreeMap.from({}));

          var year = (await Crawler.entranceGraduateYear(parentTransaction: transaction).directExecute(controller))!;
          int entranceYear = _startYear == 0 ? int.parse(year.item1) : _startYear;
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
              var tmp = await Crawler.singleGrade(
                key,
                reloadPage: false,
                parentTransaction: transaction,
              ).directExecute(controller);
              if (tmp == null) throw Exception("single grade returns null");
              result!.data[key] = tmp;

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

      transaction.throwable = e;
      Sentry.captureException(
        e,
        stackTrace: stacktrace,
        withScope: (scope) {
          scope.span = transaction;
          scope.level = SentryLevel.error;
        },
      );

      return null;
    } finally {
      isFinished = true;
      transaction.status = result != null ? const SpanStatus.ok() : const SpanStatus.internalError();
      transaction.finish();
    }

    return result;
  }
}
