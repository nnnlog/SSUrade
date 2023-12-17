import 'dart:developer';

import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/Crawler.dart';
import 'package:ssurade/types/subject/SemesterSubjectsManager.dart';

// 가변적인 controller?가 필요..
class AllGrade {
  ISentrySpan? parentTransaction;
  SemesterSubjectsManager? base;

  String task_id = "all_grade";

  factory AllGrade.get({SemesterSubjectsManager? base, ISentrySpan? parentTransaction}) => AllGrade._(base, parentTransaction);

  AllGrade._(this.base, this.parentTransaction);

  Future<SemesterSubjectsManager?> execute() async {
    final transaction = parentTransaction == null ? Sentry.startTransaction('AllGrade', task_id) : parentTransaction!.startChild(task_id);
    late ISentrySpan span;

    var start = DateTime.now();

    span = transaction.startChild("get_grade_info");
    List<Future<SemesterSubjectsManager?>> wait = [];
    wait.add(Crawler.allGradeByCategory(parentTransaction: span).execute());
    // TODO: 이수구분별 성적표 조회가 상당히 느림
    // if (base == null) {
      wait.add(Crawler.allGradeBySemester(parentTransaction: span).execute());
    // } else {
    //   wait.add(Future(() {
    //     return base;
    //   }));
    // }

    var ret = (await Future.wait(wait)).whereType<SemesterSubjectsManager>().toList(); // remove null
    span.finish(status: const SpanStatus.ok());

    if (ret.isEmpty) {
      transaction.finish(status: const SpanStatus.cancelled());
      return null;
    }

    span = transaction.startChild("merge_grade_info");
    var result = ret.removeLast();
    while (ret.isNotEmpty) {
      result.merge(ret.removeLast());
    }
    span.finish(status: const SpanStatus.ok());

    // if (base != null) {
    //   span = transaction.startChild("get_more_grade_info");
    //   List<Future<SemesterSubjects?>> wait2 = [];
    //   for (var subjects in result.getIncompleteSemester()) {
    //     wait2.add(Crawler.singleGrade(subjects.currentSemester, reloadPage: false, parentTransaction: transaction).execute());
    //   }
    //
    //   for (var element in (await Future.wait(wait2))) {
    //     if (element == null) continue;
    //     result.data[element.currentSemester]!.merge(element);
    //   }
    //   span.finish(status: const SpanStatus.ok());
    // }

    // result.cleanup();
    transaction.finish(status: const SpanStatus.ok());

    var end = DateTime.now();
    log("all_grade : ${end.millisecondsSinceEpoch - start.millisecondsSinceEpoch}");
    return result;
  }
}
