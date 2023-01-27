import 'dart:developer';

import 'package:ssurade/crawling/Crawler.dart';
import 'package:ssurade/types/subject/SemesterSubjects.dart';
import 'package:ssurade/types/subject/SemesterSubjectsManager.dart';

// 가변적인 controller?가 필요..
class AllGrade {
  SemesterSubjectsManager? base;

  factory AllGrade.get({SemesterSubjectsManager? base}) {
    return AllGrade._(base);
  }

  AllGrade._(this.base);

  Future<SemesterSubjectsManager?> execute() async {
    var start = DateTime.now();

    List<Future<SemesterSubjectsManager?>> wait = [];
    wait.add(Crawler.allGradeByCategory().execute());
    if (base == null) {
      wait.add(Crawler.allGradeBySemester().execute());
    } else {
      wait.add(Future(() {
        return base;
      }));
    }

    var ret = (await Future.wait(wait)).whereType<SemesterSubjectsManager>().toList(); // remove null
    if (ret.isEmpty) return null;
    var result = ret.removeLast();
    while (ret.isNotEmpty) {
      result.merge(ret.removeLast());
    }

    List<Future<SemesterSubjects?>> wait2 = [];
    for (var subjects in result.getIncompleteSemester()) {
      wait2.add(Crawler.singleGrade(subjects.currentSemester, reloadPage: false).execute());
    }

    if (base != null) {
      for (var element in (await Future.wait(wait2))) {
        if (element == null) continue;
        result.data[element.currentSemester]!.merge(element);
      }
    }

    result.cleanup();

    var end = DateTime.now();
    log("all_grade : ${end.millisecondsSinceEpoch - start.millisecondsSinceEpoch}");
    return result;
  }
}
