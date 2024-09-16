import 'dart:collection';

import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade_application/domain/model/semester/year_semester.dart';
import 'package:ssurade_application/domain/model/subject/semester_subjects.dart';

part 'semester_subjects_manager.g.dart';

@JsonSerializable(converters: [_DataConverter()])
class SemesterSubjectsManager {
  @JsonKey()
  final int state;

  @JsonKey()
  final SplayTreeMap<YearSemester, SemesterSubjects> data;

  const SemesterSubjectsManager({
    required this.data,
    required this.state,
  });

  factory SemesterSubjectsManager.fromJson(Map<String, dynamic> json) => _$SemesterSubjectsManagerFromJson(json);

  Map<String, dynamic> toJson() => _$SemesterSubjectsManagerToJson(this);

  bool get isEmpty => data.isEmpty;

  bool get isNotEmpty => !isEmpty;

  List<SemesterSubjects> getIncompleteSemester() {
    List<SemesterSubjects> ret = [];
    for (var subjects in data.values) {
      if (subjects.incompleteSubjects.isNotEmpty || subjects.semesterRanking.isEmpty || subjects.totalRanking.isEmpty) {
        ret.add(subjects);
      }
    }
    return ret;
  }

// static SemesterSubjectsManager? merge(SemesterSubjectsManager after, SemesterSubjectsManager before) {
//   if (after.state | before.state != STATE_FULL) return null;
//   SemesterSubjectsManager ret = SemesterSubjectsManager(SplayTreeMap(), STATE_FULL);
//   for (var key in after.data.keys) {
//     if (before.data.containsKey(key)) {
//       ret.data[key] = SemesterSubjects.merge(after.data[key]!, before.data[key]!, after.state, before.state)!;
//     }
//   }
//   return ret;
// }
//
// static SemesterSubjectsManager? merges(List<SemesterSubjectsManager> list) {
//   if (list.isEmpty) return null;
//   var result = list.removeLast();
//   while (list.isNotEmpty) {
//     result = SemesterSubjectsManager.merge(list.removeLast(), result)!;
//   }
//   return result;
// }
}

class _DataConverter extends JsonConverter<SplayTreeMap<YearSemester, SemesterSubjects>, List<dynamic>> {
  const _DataConverter();

  @override
  SplayTreeMap<YearSemester, SemesterSubjects> fromJson(List<dynamic> json) {
    var list = json.map((e) => SemesterSubjects.fromJson(e));
    return SplayTreeMap.fromIterables(list.map((e) => e.currentSemester), list);
  }

  @override
  List<dynamic> toJson(SplayTreeMap<YearSemester, SemesterSubjects> object) {
    return object.entries.map((entry) => entry.value).toList();
  }
}
