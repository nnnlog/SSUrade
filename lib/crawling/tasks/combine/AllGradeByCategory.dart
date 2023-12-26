import 'dart:async';
import 'dart:collection';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/Crawler.dart';
import 'package:ssurade/crawling/common/CrawlingTask.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/Semester.dart';
import 'package:ssurade/types/YearSemester.dart';
import 'package:ssurade/types/subject/Ranking.dart';
import 'package:ssurade/types/subject/SemesterSubjects.dart';
import 'package:ssurade/types/subject/SemesterSubjectsManager.dart';
import 'package:ssurade/types/subject/Subject.dart';

class AllGradeByCategory extends CrawlingTask<SemesterSubjectsManager> {
  factory AllGradeByCategory.get({
    ISentrySpan? parentTransaction,
  }) =>
      AllGradeByCategory._(parentTransaction);

  AllGradeByCategory._(ISentrySpan? parentTransaction) : super(parentTransaction);

  @override
  Future<SemesterSubjectsManager> internalExecute(Queue<InAppWebViewController> controllers) async {
    var controller = controllers.removeFirst();

    final transaction = parentTransaction == null ? Sentry.startTransaction('AllGradeByCategory', getTaskId()) : parentTransaction!.startChild(getTaskId());
    late ISentrySpan span;

    var viewerUrl = await Crawler.webUrlByCategory(parentTransaction: transaction).directExecute(Queue()..add(controller));
    var gradeData = await Crawler.extractDataFromViewer(viewerUrl, parentTransaction: transaction).directExecute(Queue()..add(controller));

    span = transaction.startChild("finalizing_data");
    var ret = SemesterSubjectsManager(SplayTreeMap());
    for (var _data in gradeData.rows) {
      Map<String, String> data = {};
      for (var key in _data.keys) {
        data[key] = _data[key] as String;
      }

      var rawKey = data["HUKGI"]!.split("―"); // format: 2022―1, 2022―겨울
      var key = YearSemester(int.parse(rawKey[0]), Semester.parse("${rawKey[1]}학기"));

      ret.data[key] ??= SemesterSubjects(SplayTreeMap(), Ranking(0, 0), Ranking(0, 0), key);

      var category = data["COMPL_TEXT"]!;
      var credit = double.parse(data["CPATTEMP"]!);
      var grade = data["GRADE"]!;
      var isPassFail = data["GRADESCALE"]! == "PF"; // otherwise, '100P'
      // var code = data["SE_SHORT"]!.replaceAll(RegExp("\\(|\\)"), ""); // FORMAT: 21501015(06) - 괄호 안은 분반 정보
      var code = data["SM_ID"]!; // FORMAT: 21501015
      // SUBJECT NAME (SM_TEXT에 존재하지만, 교선에 교선 분류명도 함께 있음)
      // PROF NAME (not exist)

      var subject = Subject(code, "", credit, grade, "", category, isPassFail, Subject.STATE_CATEGORY);
      ret.data[key]!.subjects[subject.code] = subject;
    }
    span.finish(status: const SpanStatus.ok());

    transaction.status = const SpanStatus.ok();
    await transaction.finish();
    return ret;
  }

  @override
  int getTimeout() {
    return globals.setting.timeoutAllGrade;
  }

  @override
  String getTaskId() {
    return "all_grade_by_category";
  }
}
