import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade_application/domain/model/chapel/chapel_attendance_status.dart';

part 'chapel_attendance.g.dart';

@CopyWith()
@JsonSerializable()
class ChapelAttendance extends Equatable implements Comparable<ChapelAttendance> {
  @JsonKey()
  final ChapelAttendanceStatus attendance;
  @JsonKey()
  final ChapelAttendanceStatus overwrittenAttendance;
  @JsonKey()
  final String affiliation;
  @JsonKey()
  final String lectureDate;
  @JsonKey()
  final String lectureEtc;
  @JsonKey()
  final String lectureName;
  @JsonKey()
  final String lectureType;
  @JsonKey()
  final String lecturer;

  const ChapelAttendance({
    required this.attendance,
    required this.overwrittenAttendance,
    required this.affiliation,
    required this.lectureDate,
    required this.lectureEtc,
    required this.lectureName,
    required this.lectureType,
    required this.lecturer,
  });

  @override
  List<Object?> get props => [attendance, overwrittenAttendance, affiliation, lectureDate, lectureEtc, lectureName, lectureType, lecturer];

  ChapelAttendanceStatus get displayAttendance => overwrittenAttendance != ChapelAttendanceStatus.unknown ? overwrittenAttendance : attendance;

  factory ChapelAttendance.fromJson(Map<String, dynamic> json) => _$ChapelAttendanceFromJson(json);

  Map<String, dynamic> toJson() => _$ChapelAttendanceToJson(this);

  @override
  int compareTo(ChapelAttendance other) {
    return lectureDate.compareTo(other.lectureDate);
  }

// static ChapelAttendanceInformation merge(
//     ChapelAttendanceInformation after, ChapelAttendanceInformation before) {
//   if (after.overwrittenAttendance == ChapelAttendance.unknown) {
//     after.overwrittenAttendance = before.overwrittenAttendance;
//   }
//
//   return after;
// }
}
