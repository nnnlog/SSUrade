import 'dart:collection';

import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade/types/YearSemester.dart';
import 'package:ssurade/types/subject/Ranking.dart';
import 'package:ssurade/types/subject/Subject.dart';
import 'package:ssurade/types/subject/gradeTable.dart';

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

  SemesterSubjects(this.subjects, this.semesterRanking, this.totalRanking, this.currentSemester);

  factory SemesterSubjects.fromJson(Map<String, dynamic> json) => _$SemesterSubjectsFromJson(json);

  Map<String, dynamic> toJson() => _$SemesterSubjectsToJson(this);

  bool get isEmpty => subjects.isEmpty;

  bool get isNotEmpty => !isEmpty;

  SemesterSubjects merge(SemesterSubjects other) {
    for (var subject in other.subjects.values) {
      if (subjects.containsKey(subject.code)) {
        subjects[subject.code]!.merge(subject);
      } else {
        subjects[subject.code] = subject;
      }
    }
    if (other.semesterRanking.isNotEmpty) semesterRanking = other.semesterRanking;
    if (other.totalRanking.isNotEmpty) totalRanking = other.totalRanking;
    return this;
  }

  List<Subject> getIncompleteSubjects() {
    List<Subject> ret = [];
    for (var subject in subjects.values) {
      if (subject.isEmpty) {
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
    double totalGrade = 0, totalCredit = 0;

    for (var data in subjects.values) {
      double? score = gradeTable[data.grade];
      if (score == null) continue; // not available
      if (data.isPassFail) continue; // Pass/Fail subject
      totalGrade += score * data.credit; // Fail subject's weight(score) is zero
      totalCredit += data.credit;
    }
    if (totalCredit == 0) return 0;
    return totalGrade / totalCredit;
  }

  double get averageMajorGrade {
    double totalGrade = 0, totalCredit = 0;

    for (var data in subjects.values) {
      if (!data.isMajor) continue;

      double? score = gradeTable[data.grade];
      if (score == null) continue; // not available
      if (data.isPassFail) continue; // Pass/Fail subject
      totalGrade += score * data.credit; // Fail subject's weight(score) is zero
      totalCredit += data.credit;
    }
    if (totalCredit == 0) return 0;
    return totalGrade / totalCredit;
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
