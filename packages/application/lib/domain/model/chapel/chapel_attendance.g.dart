// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapel_attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChapelAttendance _$ChapelAttendanceFromJson(Map<String, dynamic> json) =>
    ChapelAttendance(
      attendance: $enumDecodeNullable(
              _$ChapelAttendanceStatusEnumMap, json['attendance']) ??
          ChapelAttendanceStatus.unknown,
      overwrittenAttendance: $enumDecodeNullable(
              _$ChapelAttendanceStatusEnumMap, json['overwrittenAttendance']) ??
          ChapelAttendanceStatus.unknown,
      affiliation: json['affiliation'] as String? ?? "",
      lectureDate: json['lectureDate'] as String? ?? "",
      lectureEtc: json['lectureEtc'] as String? ?? "",
      lectureName: json['lectureName'] as String? ?? "",
      lectureType: json['lectureType'] as String? ?? "",
      lecturer: json['lecturer'] as String? ?? "",
    );

Map<String, dynamic> _$ChapelAttendanceToJson(ChapelAttendance instance) =>
    <String, dynamic>{
      'attendance': _$ChapelAttendanceStatusEnumMap[instance.attendance]!,
      'overwrittenAttendance':
          _$ChapelAttendanceStatusEnumMap[instance.overwrittenAttendance]!,
      'affiliation': instance.affiliation,
      'lectureDate': instance.lectureDate,
      'lectureEtc': instance.lectureEtc,
      'lectureName': instance.lectureName,
      'lectureType': instance.lectureType,
      'lecturer': instance.lecturer,
    };

const _$ChapelAttendanceStatusEnumMap = {
  ChapelAttendanceStatus.unknown: 'unknown',
  ChapelAttendanceStatus.absent: 'absent',
  ChapelAttendanceStatus.attend: 'attend',
};
