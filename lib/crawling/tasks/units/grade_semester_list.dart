import 'dart:async';
import 'dart:collection';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/crawling_task.dart';
import 'package:ssurade/crawling/common/webview_controller_extension.dart';
import 'package:ssurade/types/semester/semester.dart';
import 'package:ssurade/types/semester/year_semester.dart';
import 'package:ssurade/types/subject/ranking.dart';
import 'package:tuple/tuple.dart';

class GradeSemesterList extends CrawlingTask<Map<YearSemester, Tuple2<Ranking, Ranking>>> {
  factory GradeSemesterList.get({
    ISentrySpan? parentTransaction,
  }) =>
      GradeSemesterList._(parentTransaction);

  GradeSemesterList._(super.parentTransaction);

  @override
  String getTaskId() {
    return "grade_semester_list";
  }

  @override
  int getTimeout() {
    return 10;
  }

  @override
  Future<Map<YearSemester, Tuple2<Ranking, Ranking>>> internalExecute(Queue<InAppWebViewController> controllers, [Completer? onComplete]) async {
    var controller = controllers.removeFirst();

    final transaction = parentTransaction == null ? Sentry.startTransaction("GradeSemesterList", getTaskId()) : parentTransaction!.startChild(getTaskId());
    late ISentrySpan span;

    await controller.customLoadPage(
      "https://ecc.ssu.ac.kr/sap/bc/webdynpro/SAP/ZCMB3W0017?sap-language=KO",
      parentTransaction: transaction,
    );

    span = transaction.startChild("execute_js");
    var data = (await controller.callAsyncJavaScript(functionBody: "return await ssurade.crawl.getGradeSemesterList().catch(() => {});"))!.value;
    span.finish(status: const SpanStatus.ok());

    span = transaction.startChild("finalizing_data");
    var ret = <YearSemester, Tuple2<Ranking, Ranking>>{};
    for (var datum in data) {
      ret[YearSemester(int.parse(datum['year']), Semester.parse(datum['semester']))] = Tuple2(Ranking.parse(datum['semester_rank']), Ranking.parse(datum['total_rank']));
    }

    var year = DateTime.now().year, month = DateTime.now().month;
    if (month <= DateTime.january) {
      year--;
    }
    for (var semester in Semester.values) {
      var key = YearSemester(year, semester);
      if (!ret.containsKey(key)) {
        ret[key] = const Tuple2(Ranking.unknown, Ranking.unknown);
      }
    }
    span.finish(status: const SpanStatus.ok());

    transaction.finish(status: const SpanStatus.ok());

    return ret;
  }
}
