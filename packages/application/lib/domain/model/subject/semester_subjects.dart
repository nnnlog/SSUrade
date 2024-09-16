import 'dart:collection';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade_application/domain/model/semester/year_semester.dart';
import 'package:ssurade_application/domain/model/subject/grade_table.dart';
import 'package:ssurade_application/domain/model/subject/ranking.dart';
import 'package:ssurade_application/domain/model/subject/subject.dart';

part 'semester_subjects.g.dart';

@CopyWith()
@JsonSerializable(converters: [_DataConverter()])
class SemesterSubjects extends Equatable {
  @JsonKey()
  final SplayTreeMap<String, Subject> subjects;
  @JsonKey()
  final Ranking semesterRanking;
  @JsonKey()
  final Ranking totalRanking;
  @JsonKey()
  final YearSemester currentSemester; // cannot change after construction, use for key of Set

  const SemesterSubjects({
    required this.subjects,
    required this.semesterRanking,
    required this.totalRanking,
    required this.currentSemester,
  });

  factory SemesterSubjects.fromJson(Map<String, dynamic> json) => _$SemesterSubjectsFromJson(json);

  Map<String, dynamic> toJson() => _$SemesterSubjectsToJson(this);

  bool get isEmpty => subjects.isEmpty;

  bool get isNotEmpty => !isEmpty;

  List<Subject> get incompleteSubjects {
    List<Subject> ret = [];
    for (var subject in subjects.values) {
      if (subject.grade.isEmpty) {
        ret.add(subject);
      }
    }
    return ret;
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
      int? score = GradeTable.scores[data.grade];
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
      int? score = GradeTable.scores[data.grade];
      if (score == null) continue; // not available
      if (data.isPassFail) continue; // Pass/Fail subject
      if (data.grade == "P") continue; // Pass subject (이수구분별 성적표 미작동 시)
      totalGrade += (score * data.credit).toInt(); // Fail subject's weight(score) is zero
      totalCredit += (data.credit * 10).toInt();
    }
    if (totalCredit == 0) return 0;
    return ((totalGrade * 100) ~/ totalCredit) / 100;
  }

  @override
  List<Object?> get props => [subjects, semesterRanking, totalRanking, currentSemester];

// static SemesterSubjects? merge(SemesterSubjects after, SemesterSubjects before, int stateAfter, int stateBefore) {
//   if (stateAfter | stateBefore != STATE_FULL) return null;
//
//   for (var key in after.subjects.keys) {
//     if (before.subjects.containsKey(key)) {
//       after.subjects[key] = Subject.merge(after.subjects[key]!, before.subjects[key]!, stateAfter, stateBefore)!;
//     }
//   }
//
//   if ((stateAfter & STATE_SEMESTER == 0) && (stateBefore & STATE_SEMESTER > 0)) {
//     if (before.semesterRanking.isNotEmpty) after.semesterRanking = before.semesterRanking;
//     if (before.totalRanking.isNotEmpty) after.totalRanking = before.totalRanking;
//   }
//
//   return after;
// }
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
