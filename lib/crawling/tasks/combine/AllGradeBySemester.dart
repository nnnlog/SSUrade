import 'dart:collection';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/Crawler.dart';
import 'package:ssurade/crawling/common/CrawlingTask.dart';
import 'package:ssurade/crawling/error/UnauthenticatedExcpetion.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/subject/SemesterSubjectsManager.dart';

class AllGradeBySemester extends CrawlingTask<SemesterSubjectsManager> {
  factory AllGradeBySemester.get({
    ISentrySpan? parentTransaction,
  }) =>
      AllGradeBySemester._(parentTransaction);

  AllGradeBySemester._(ISentrySpan? parentTransaction) : super(parentTransaction);

  @override
  Future<SemesterSubjectsManager> internalExecute(Queue<InAppWebViewController> controllers) async {
    var controller = controllers.removeFirst();

    final transaction = parentTransaction == null ? Sentry.startTransaction('AllGradeBySemester', getTaskId()) : parentTransaction!.startChild(getTaskId());

    SemesterSubjectsManager? result;
    if (!await Crawler.loginSession(parentTransaction: transaction).directExecute(Queue()..add(controller))) {
      throw UnauthenticatedException();
    }

    var map = await Crawler.gradeSemesterList(parentTransaction: transaction).directExecute(Queue()..add(controller));

    result = SemesterSubjectsManager(SplayTreeMap.from({}));

    for (var key in map.keys) {
      var tmp = await Crawler.singleGrade(
        key,
        reloadPage: false,
        getRanking: false,
        parentTransaction: transaction,
      ).directExecute(Queue()..add(controller));
      if (map.containsKey(key)) {
        tmp.semesterRanking = map[key]!.item1;
        tmp.totalRanking = map[key]!.item2;
      }
      result.data[key] = tmp;

      if (result.data[key]?.subjects.isEmpty == true) {
        result.data.remove(key);
      }
    }

    return result;
  }

  @override
  int getTimeout() {
    return globals.setting.timeoutAllGrade;
  }

  @override
  String getTaskId() {
    return "all_grade_by_semester";
  }
}
