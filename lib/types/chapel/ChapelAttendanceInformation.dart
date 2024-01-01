import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade/types/chapel/chapel_attendance.dart';

part 'ChapelAttendanceInformation.g.dart';

@JsonSerializable()
class ChapelAttendanceInformation with Comparable<ChapelAttendanceInformation> {
  @JsonKey()
  final ChapelAttendance attendance;
  @JsonKey()
  ChapelAttendance overwrittenAttendance;
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

  ChapelAttendanceInformation(this.attendance, this.overwrittenAttendance, this.affiliation, this.lectureDate, this.lectureEtc, this.lectureName, this.lectureType, this.lecturer);

  ChapelAttendance get displayAttendance => overwrittenAttendance != ChapelAttendance.unknown ? overwrittenAttendance : attendance;

  factory ChapelAttendanceInformation.fromJson(Map<String, dynamic> json) => _$ChapelAttendanceInformationFromJson(json);

  Map<String, dynamic> toJson() => _$ChapelAttendanceInformationToJson(this);

  @override
  String toString() {
    return "$runtimeType(attendance=$attendance, overwrittenAttendance=$overwrittenAttendance, affiliation=$affiliation, lectureDate=$lectureDate, lectureEtc=$lectureEtc, lectureName=$lectureName, lectureType=$lectureType, lecturer=$lecturer)";
  }

  @override
  int compareTo(ChapelAttendanceInformation other) {
    return lectureDate.compareTo(other.lectureDate);
  }
}
