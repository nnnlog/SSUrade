import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade_application/domain/model/chapel/chapel_attendance_status.dart';

part 'chapel_attendance.g.dart';

@JsonSerializable()
class ChapelAttendance implements Comparable<ChapelAttendance> {
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
    this.attendance = ChapelAttendanceStatus.unknown,
    this.overwrittenAttendance = ChapelAttendanceStatus.unknown,
    this.affiliation = "",
    this.lectureDate = "",
    this.lectureEtc = "",
    this.lectureName = "",
    this.lectureType = "",
    this.lecturer = "",
  });

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
