import 'dart:async';
import 'dart:collection';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/crawler.dart';
import 'package:ssurade/crawling/common/crawling_task.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/subject/semester_subjects_manager.dart';
import 'package:ssurade/types/subject/state.dart';

class AllGrade extends CrawlingTask<SemesterSubjectsManager> {
  SemesterSubjectsManager? base;

  factory AllGrade.get({SemesterSubjectsManager? base, ISentrySpan? parentTransaction}) => AllGrade._(base, parentTransaction);

  AllGrade._(this.base, ISentrySpan? parentTransaction) : super(parentTransaction);

  @override
  Future<SemesterSubjectsManager> internalExecute(Queue<InAppWebViewController> controllers, [Completer? onComplete]) async {
    var con1 = controllers.removeFirst();
    var con2 = controllers.removeFirst();

    final transaction = parentTransaction == null ? Sentry.startTransaction('AllGrade', getTaskId()) : parentTransaction!.startChild(getTaskId());
    late ISentrySpan span;

    span = transaction.startChild("get_grade_info");
    List<Future<SemesterSubjectsManager>> wait = [];

    wait.add(Crawler.allGradeByCategory(parentTransaction: span).directExecute(Queue()..add(con1)).catchError((_) => SemesterSubjectsManager(SplayTreeMap(), STATE_CATEGORY)));
    wait.add(Crawler.allGradeBySemester(parentTransaction: span).directExecute(Queue()..add(con2)).catchError((_) => SemesterSubjectsManager(SplayTreeMap(), STATE_SEMESTER)));

    var ret = (await Future.wait(wait))..removeWhere((element) => element.isEmpty);
    span.finish(status: const SpanStatus.ok());

    if (ret.isEmpty) {
      transaction.finish(status: const SpanStatus.dataLoss());
      throw Exception("getGradeInfo is empty");
    }

    span = transaction.startChild("merge_grade_info");
    var result = SemesterSubjectsManager.merges(ret)!;
    span.finish(status: const SpanStatus.ok());

    transaction.finish(status: const SpanStatus.ok());
    return result;
  }

  @override
  int getTimeout() {
    return globals.setting.timeoutAllGrade;
  }

  @override
  String getTaskId() {
    return "all_grade";
  }

  @override
  int getWebViewCount() {
    return 2;
  }
}
