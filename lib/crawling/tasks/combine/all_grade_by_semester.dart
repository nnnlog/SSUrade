import 'dart:async';
import 'dart:collection';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/crawler.dart';
import 'package:ssurade/crawling/common/crawling_task.dart';
import 'package:ssurade/crawling/error/unauthenticated_exception.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/semester/year_semester.dart';
import 'package:ssurade/types/subject/ranking.dart';
import 'package:ssurade/types/subject/semester_subjects_manager.dart';
import 'package:ssurade/types/subject/state.dart';
import 'package:tuple/tuple.dart';

class AllGradeBySemester extends CrawlingTask<SemesterSubjectsManager> {
  Map<YearSemester, Tuple2<Ranking, Ranking>> map;

  factory AllGradeBySemester.get({
    Map<YearSemester, Tuple2<Ranking, Ranking>> map = const {},
    ISentrySpan? parentTransaction,
  }) =>
      AllGradeBySemester._(map, parentTransaction);

  AllGradeBySemester._(this.map, ISentrySpan? parentTransaction) : super(parentTransaction);

  @override
  Future<SemesterSubjectsManager> internalExecute(Queue<InAppWebViewController> controllers, [Completer? onComplete]) async {
    var controller = controllers.removeFirst();

    final transaction = parentTransaction == null ? Sentry.startTransaction('AllGradeBySemester', getTaskId()) : parentTransaction!.startChild(getTaskId());

    SemesterSubjectsManager? result;
    if (!await Crawler.loginSession(parentTransaction: transaction).directExecute(Queue()..add(controller))) {
      throw UnauthenticatedException();
    }

    var semesters = map;
    if (map.isEmpty) semesters = await Crawler.gradeSemesterList(parentTransaction: transaction).directExecute(Queue()..add(controller));

    result = SemesterSubjectsManager(SplayTreeMap.from({}), STATE_SEMESTER);

    for (var key in semesters.keys) {
      var tmp = await Crawler.singleGradeBySemester(
        key,
        reloadPage: false,
        getRanking: false,
        parentTransaction: transaction,
      ).directExecute(Queue()..add(controller));
      if (tmp.isEmpty) continue;

      tmp.semesterRanking = map[key]!.item1;
      tmp.totalRanking = map[key]!.item2;

      result.data[key] = tmp;
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
