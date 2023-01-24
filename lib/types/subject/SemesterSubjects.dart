import 'dart:collection';

import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade/types/YearSemester.dart';
import 'package:ssurade/types/subject/Ranking.dart';
import 'package:ssurade/types/subject/Subject.dart';
import 'package:ssurade/types/subject/gradeTable.dart';
import 'package:ssurade/utils/PassFailSubjects.dart';

part 'SemesterSubjects.g.dart';

@JsonSerializable(converters: [_DataConverter()])
class SemesterSubjects {
  @JsonKey()
  SplayTreeSet<Subject> subjects;
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
}

class _DataConverter extends JsonConverter<SplayTreeSet<Subject>, List<dynamic>> {
  const _DataConverter();

  @override
  SplayTreeSet<Subject> fromJson(List<dynamic> json) {
    return SplayTreeSet.of(json.map((e) => Subject.fromJson(e)));
  }

  @override
  List<Subject> toJson(SplayTreeSet<Subject> object) {
    return object.toList();
  }
}
