import 'dart:collection';
import 'dart:core';

import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade/types/chapel/chapel_attendance.dart';
import 'package:ssurade/types/chapel/chapel_attendance_information.dart';
import 'package:ssurade/types/semester/year_semester.dart';
import 'package:ssurade/utils/set.dart';

part 'chapel_information.g.dart';

@JsonSerializable(converters: [_DataConverter()])
class ChapelInformation with Comparable<ChapelInformation> {
  @JsonKey()
  YearSemester currentSemester;
  @JsonKey()
  SplayTreeSet<ChapelAttendanceInformation> attendances;
  @JsonKey()
  String subjectCode;
  @JsonKey()
  String subjectPlace;
  @JsonKey()
  String subjectTime;
  @JsonKey()
  String floor;
  @JsonKey()
  String seatNo;

  ChapelInformation(this.currentSemester, this.attendances, [this.subjectCode = "", this.subjectPlace = "", this.subjectTime = "", this.floor = "", this.seatNo = ""]);

  int get absentCount => attendances.map((e) => e.displayAttendance == ChapelAttendance.absent ? 1 : 0).reduce((value, element) => value + element);

  int get attendCount => attendances.map((e) => e.displayAttendance == ChapelAttendance.attend ? 1 : 0).reduce((value, element) => value + element);

  int get passAttendCount => attendances.length - attendances.length ~/ 3;

  factory ChapelInformation.fromJson(Map<String, dynamic> json) => _$ChapelInformationFromJson(json);

  Map<String, dynamic> toJson() => _$ChapelInformationToJson(this);

  @override
  String toString() {
    return "$runtimeType(currentSemester=$currentSemester, attendances=$attendances, subjectCode=$subjectCode, subjectPlace=$subjectPlace, subjectTime=$subjectTime, floor=$floor, seatNo=$seatNo)";
  }

  @override
  int compareTo(ChapelInformation other) {
    return currentSemester.compareTo(other.currentSemester);
  }

  static ChapelInformation merge(ChapelInformation after, ChapelInformation before) {
    for (var attendance in after.attendances) {
      ChapelAttendanceInformation.merge(attendance, before.attendances[attendance.lectureDate]!);
    }

    return after;
  }
}

class _DataConverter extends JsonConverter<SplayTreeSet<ChapelAttendanceInformation>, List<dynamic>> {
  const _DataConverter();

  @override
  SplayTreeSet<ChapelAttendanceInformation> fromJson(List<dynamic> json) {
    return SplayTreeSet.from(json.map((e) => ChapelAttendanceInformation.fromJson(e)));
  }

  @override
  List<dynamic> toJson(SplayTreeSet<ChapelAttendanceInformation> object) {
    return object.toList();
  }
}
