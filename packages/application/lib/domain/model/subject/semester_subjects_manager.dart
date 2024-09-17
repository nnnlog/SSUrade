import 'dart:collection';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade_application/domain/model/semester/year_semester.dart';
import 'package:ssurade_application/domain/model/subject/semester_subjects.dart';
import 'package:ssurade_application/domain/model/subject/state.dart';

part 'semester_subjects_manager.g.dart';

@CopyWith()
@JsonSerializable(converters: [_DataConverter()])
class SemesterSubjectsManager extends Equatable {
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

  @override
  List<Object?> get props => [state, data];

  static SemesterSubjectsManager? merge(SemesterSubjectsManager after, SemesterSubjectsManager before) {
    if (after.state | before.state != SubjectState.full) return null;
    return after.copyWith(
      data: SplayTreeMap.fromIterable(
        after.data.values.map((value) {
          var key = value.currentSemester;
          if (before.data.containsKey(key)) {
            return SemesterSubjects.merge(after.data[key]!, before.data[key]!, after.state, before.state);
          }
          return value;
        }),
        key: (value) => value.currentSemester,
      ),
    );
  }
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
