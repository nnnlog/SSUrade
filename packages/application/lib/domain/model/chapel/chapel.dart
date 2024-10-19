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
  final SplayTreeSet<ChapelAttendance> attendances;
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

  int get absentCount => attendances.map((e) => e.displayAttendance == ChapelAttendanceStatus.absent ? 1 : 0).reduce((value, element) => value + element);

  int get attendCount => attendances.map((e) => e.displayAttendance == ChapelAttendanceStatus.attend ? 1 : 0).reduce((value, element) => value + element);

  int get passAttendCount => attendances.length - attendances.length ~/ 3;

  factory Chapel.fromJson(Map<String, dynamic> json) => _$ChapelFromJson(json);

  Map<String, dynamic> toJson() => _$ChapelToJson(this);

  @override
  int compareTo(Chapel other) {
    return currentSemester.compareTo(other.currentSemester);
  }

// static ChapelInformation merge(
//     ChapelInformation after, ChapelInformation before) {
//   for (var attendance in after.attendances) {
//     ChapelAttendanceInformation.merge(
//         attendance, before.attendances[attendance.lectureDate]!);
//   }
//
//   return after;
// }
}

class _DataConverter extends JsonConverter<SplayTreeSet<ChapelAttendance>, List<dynamic>> {
  const _DataConverter();

  @override
  SplayTreeSet<ChapelAttendance> fromJson(List<dynamic> json) {
    return SplayTreeSet.from(json.map((e) => ChapelAttendance.fromJson(e)));
  }

  @override
  List<dynamic> toJson(SplayTreeSet<ChapelAttendance> object) {
    return object.toList();
  }
}
