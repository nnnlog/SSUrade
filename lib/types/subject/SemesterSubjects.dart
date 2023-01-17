import 'package:ssurade/types/YearSemester.dart';
import 'package:ssurade/types/subject/Ranking.dart';
import 'package:ssurade/types/subject/Subject.dart';
import 'package:ssurade/types/subject/gradeTable.dart';
import 'package:ssurade/utils/PassFailSubjects.dart';
import 'dart:developer';

class SemesterSubjects {
  List<Subject> subjects;
  Ranking semesterRanking, totalRanking;
  final YearSemester currentSemester; // cannot change after construction, use for key of Map
  Map<String, bool>? list;

  SemesterSubjects(this.subjects, this.semesterRanking, this.totalRanking, this.currentSemester);

  Future<void> loadPassFailSubjects() async {
    list ??= await getPassFailSubjects(currentSemester);
  }

  double get totalCredit {
    double ret = 0;
    for (var data in subjects) {
      ret += data.credit;
    }

    return ret;
  }

  double get averageGrade {
    double totalGrade = 0, totalCredit = 0;

    for (var data in subjects) {
      double? score = gradeTable[data.grade];
      if (score == null) continue; // not available
      if (list!.containsKey(data.code)) continue; // not calculate for P/F subject
      if (data.grade == "P") continue; // not calculate for P subject (explicitly)
      totalGrade += score * data.credit; // Fail subject's weight(score) is zero
      totalCredit += data.credit;
    }
    if (totalCredit == 0) return 0;
    return totalGrade / totalCredit;
  }

  @override
  String toString() =>
      "$runtimeType(subjects=${subjects.toString()}, semesterRanking=${semesterRanking.toString()}, totalRanking=${totalRanking.toString()}, currentSemester=${currentSemester.toString()})";

  // FILE I/O
  static const String _subjects = 'subjects', _semester_rank = 'semester_rank', _total_rank = 'total_rank', _semester = '_semester';

  Map<String, dynamic> toJSON() => {
        _subjects: subjects.map((e) => e.toJSON()).toList(),
        _semester_rank: semesterRanking.toKey(),
        _total_rank: totalRanking.toKey(),
        _semester: currentSemester.toKey(),
      };

  static SemesterSubjects fromJSON(Map<String, dynamic> json) => SemesterSubjects(
        json[_subjects].map<Subject>((e) => Subject.fromJSON(e)).toList(),
        Ranking.fromKey(json[_semester_rank]),
        Ranking.fromKey(json[_total_rank]),
        YearSemester.fromKey(json[_semester]),
      );
}
