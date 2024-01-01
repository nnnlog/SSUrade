import 'dart:async';
import 'dart:collection';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/crawling/common/crawler.dart';
import 'package:ssurade/crawling/common/crawling_task.dart';
import 'package:ssurade/globals.dart' as globals;
import 'package:ssurade/types/semester/semester.dart';
import 'package:ssurade/types/semester/year_semester.dart';
import 'package:ssurade/types/subject/ranking.dart';
import 'package:ssurade/types/subject/semester_subjects.dart';
import 'package:ssurade/types/subject/semester_subjects_manager.dart';
import 'package:ssurade/types/subject/state.dart';
import 'package:ssurade/types/subject/subject.dart';

class AllGradeByCategory extends CrawlingTask<SemesterSubjectsManager> {
  factory AllGradeByCategory.get({
    ISentrySpan? parentTransaction,
  }) =>
      AllGradeByCategory._(parentTransaction);

  AllGradeByCategory._(ISentrySpan? parentTransaction) : super(parentTransaction);

  @override
  Future<SemesterSubjectsManager> internalExecute(Queue<InAppWebViewController> controllers, [Completer? onComplete]) async {
    var controller = controllers.removeFirst();

    final transaction = parentTransaction == null ? Sentry.startTransaction('AllGradeByCategory', getTaskId()) : parentTransaction!.startChild(getTaskId());
    late ISentrySpan span;

    var viewerUrl = await Crawler.webUrlByCategory(parentTransaction: transaction).directExecute(Queue()..add(controller));
    var gradeData = await Crawler.extractDataFromViewer(viewerUrl, parentTransaction: transaction).directExecute(Queue()..add(controller));

    span = transaction.startChild("finalizing_data");
    var ret = SemesterSubjectsManager(SplayTreeMap(), STATE_CATEGORY);
    for (var _data in gradeData.rows) {
      Map<String, String> data = {};
      for (var key in _data.keys) {
        data[key] = _data[key] as String;
      }

      var rawKey = data["HUKGI"]!.split("―"); // format: 2022―1, 2022―겨울
      var key = YearSemester(int.parse(rawKey[0]), Semester.parse("${rawKey[1]}학기"));

      ret.data[key] ??= SemesterSubjects(SplayTreeMap(), key, Ranking(0, 0), Ranking(0, 0));

      var category = data["COMPL_TEXT"]!;
      var credit = double.parse(data["CPATTEMP"]!);
      var grade = data["GRADE"]!; // 성적 기호
      var score = data["GRADESYMBOL"]!; // 최종 점수 (근데 이름이 왜 이래)
      var isPassFail = data["GRADESCALE"]! == "PF"; // otherwise, '100P'
      // var code = data["SE_SHORT"]!.replaceAll(RegExp("\\(|\\)"), ""); // FORMAT: 21501015(06) - 괄호 안은 분반 정보
      var code = data["SM_ID"]!; // FORMAT: 21501015
      var info = data["SM_INFO"]!; // 재수강 시 어떻게 표기되는지 모릅니다. / 과목 정보(재수강되어 졸업 사정되지 않는 과목 / 영어 강의 등..)
      // SUBJECT NAME (SM_TEXT에 존재하지만, 교선에 교선 분류명도 함께 있음)
      // PROF NAME (not exist)

      var subject = Subject(code, "", credit, grade, score, "", category, isPassFail, info);
      ret.data[key]!.subjects[subject.code] = subject;
    }
    span.finish(status: const SpanStatus.ok());

    transaction.status = const SpanStatus.ok();
    transaction.finish();
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
