import 'dart:collection';
import 'dart:core';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade_application/domain/model/chapel/chapel_attendance.dart';
import 'package:ssurade_application/domain/model/chapel/chapel_attendance_status.dart';
import 'package:ssurade_application/domain/model/semester/year_semester.dart';

part 'chapel.g.dart';

@CopyWith()
@JsonSerializable(converters: [_DataConverter()])
class Chapel extends Equatable implements Comparable<Chapel> {
  @JsonKey()
  final YearSemester currentSemester;
  @JsonKey()
  final SplayTreeMap<String, ChapelAttendance> attendances;
  @JsonKey()
  final String subjectCode;
  @JsonKey()
  final String subjectPlace;
  @JsonKey()
  final String subjectTime;
  @JsonKey()
  final String floor;
  @JsonKey()
  final String seatNo;

  const Chapel({
    required this.currentSemester,
    required this.attendances,
    required this.subjectCode,
    required this.subjectPlace,
    required this.subjectTime,
    required this.floor,
    required this.seatNo,
  });

  @override
  List<Object?> get props => [currentSemester, attendances, subjectCode, subjectPlace, subjectTime, floor, seatNo];

  int get absentCount => attendances.values.where((e) => e.displayAttendance == ChapelAttendanceStatus.absent).length;

  int get attendCount => attendances.values.where((e) => e.displayAttendance == ChapelAttendanceStatus.attend).length;

  int get passAttendCount => attendances.length - attendances.length ~/ 3;

  factory Chapel.fromJson(Map<String, dynamic> json) => _$ChapelFromJson(json);

  Map<String, dynamic> toJson() => _$ChapelToJson(this);

  @override
  int compareTo(Chapel other) {
    return currentSemester.compareTo(other.currentSemester);
  }
}

class _DataConverter extends JsonConverter<SplayTreeMap<String, ChapelAttendance>, List<dynamic>> {
  const _DataConverter();

  @override
  SplayTreeMap<String, ChapelAttendance> fromJson(List<dynamic> json) {
    return SplayTreeMap.fromIterable(
      json.map((e) => ChapelAttendance.fromJson(e)),
      key: (e) => e.lectureDate,
    );
  }

  @override
  List<dynamic> toJson(SplayTreeMap<String, ChapelAttendance> object) {
    return object.values.toList();
  }
}
