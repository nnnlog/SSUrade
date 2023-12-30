import 'dart:collection';

import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade/types/Semester.dart';
import 'package:ssurade/types/YearSemester.dart';
import 'package:ssurade/types/subject/Ranking.dart';
import 'package:ssurade/types/subject/Subject.dart';
import 'package:ssurade/types/subject/gradeTable.dart';
import 'package:ssurade/types/subject/state.dart';

part 'SemesterSubjects.g.dart';

@JsonSerializable(converters: [_DataConverter()])
class SemesterSubjects {
  @JsonKey()
  SplayTreeMap<String, Subject> subjects;
  @JsonKey()
  Ranking semesterRanking;
  @JsonKey()
  Ranking totalRanking;
  @JsonKey()
  final YearSemester currentSemester; // cannot change after construction, use for key of Set

  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  Map<String, bool>? list;

  SemesterSubjects(this.subjects, [this.currentSemester = const YearSemester(0, Semester.first), this.semesterRanking = Ranking.unknown, this.totalRanking = Ranking.unknown]);

  factory SemesterSubjects.fromJson(Map<String, dynamic> json) => _$SemesterSubjectsFromJson(json);

  Map<String, dynamic> toJson() => _$SemesterSubjectsToJson(this);

  bool get isEmpty => subjects.isEmpty;

  bool get isNotEmpty => !isEmpty;

  List<Subject> getIncompleteSubjects() {
    List<Subject> ret = [];
    for (var subject in subjects.values) {
      if (subject.grade.isEmpty) {
        ret.add(subject);
      }
    }
    return ret;
  }

  void cleanup() {
    for (var subject in getIncompleteSubjects()) {
      subjects.remove(subject.code);
    }
  }

  double get totalCredit {
    double ret = 0;
    for (var data in subjects.values) {
      ret += data.credit;
    }

    return ret;
  }

  double get majorCredit {
    double ret = 0;
    for (var data in subjects.values) {
      if (data.isMajor) {
        // 전공 선택 / 전공 필수 / 전공 기초
        ret += data.credit;
      }
    }

    return ret;
  }

  double get averageGrade {
    int totalGrade = 0, totalCredit = 0;

    for (var data in subjects.values) {
      int? score = gradeTable[data.grade];
      if (score == null) continue; // not available
      if (data.isPassFail) continue; // Pass/Fail subject
      if (data.grade == "P") continue; // Pass subject (이수구분별 성적표 미작동 시)
      totalGrade += score * data.credit.toInt(); // Fail subject's weight(score) is zero
      totalCredit += (data.credit * 10).toInt();
    }
    if (totalCredit == 0) return 0;
    return ((totalGrade * 100) ~/ totalCredit) / 100;
  }

  double get averageMajorGrade {
    int totalGrade = 0, totalCredit = 0;

    for (var data in subjects.values) {
      if (!data.isMajor) continue;
      int? score = gradeTable[data.grade];
      if (score == null) continue; // not available
      if (data.isPassFail) continue; // Pass/Fail subject
      if (data.grade == "P") continue; // Pass subject (이수구분별 성적표 미작동 시)
      totalGrade += (score * data.credit).toInt(); // Fail subject's weight(score) is zero
      totalCredit += (data.credit).toInt();
    }
    if (totalCredit == 0) return 0;
    return ((totalGrade * 100) ~/ totalCredit) / 100;
  }

  static SemesterSubjects? merge(SemesterSubjects after, SemesterSubjects before, int stateAfter, int stateBefore) {
    if (stateAfter | stateBefore != STATE_FULL) return null;

    for (var key in after.subjects.keys) {
      if (before.subjects.containsKey(key)) {
        after.subjects[key] = Subject.merge(after.subjects[key]!, before.subjects[key]!, stateAfter, stateBefore)!;
      }
    }

    if ((stateAfter & STATE_SEMESTER == 0) && (stateBefore & STATE_SEMESTER > 0)) {
      if (before.semesterRanking.isNotEmpty) after.semesterRanking = before.semesterRanking;
      if (before.totalRanking.isNotEmpty) after.totalRanking = before.totalRanking;
    }

    return after;
  }

  @override
  String toString() =>
      "$runtimeType(subjects=${subjects.toString()}, semesterRanking=${semesterRanking.toString()}, totalRanking=${totalRanking.toString()}, currentSemester=${currentSemester.toString()})";
}

class _DataConverter extends JsonConverter<SplayTreeMap<String, Subject>, List<dynamic>> {
  const _DataConverter();

  @override
  SplayTreeMap<String, Subject> fromJson(List<dynamic> json) {
    var list = json.map((e) => Subject.fromJson(e));
    return SplayTreeMap.fromIterables(list.map((e) => e.code), list);
  }

  @override
  List<Subject> toJson(SplayTreeMap<String, Subject> object) {
    return object.values.toList();
  }
}
