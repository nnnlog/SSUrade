// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapel_attendance_information.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChapelAttendanceInformation _$ChapelAttendanceInformationFromJson(Map<String, dynamic> json) => ChapelAttendanceInformation(
      attendance: $enumDecodeNullable(_$ChapelAttendanceEnumMap, json['attendance']) ?? ChapelAttendance.unknown,
      overwrittenAttendance: $enumDecodeNullable(_$ChapelAttendanceEnumMap, json['overwrittenAttendance']) ?? ChapelAttendance.unknown,
      affiliation: json['affiliation'] as String? ?? "",
      lectureDate: json['lectureDate'] as String? ?? "",
      lectureEtc: json['lectureEtc'] as String? ?? "",
      lectureName: json['lectureName'] as String? ?? "",
      lectureType: json['lectureType'] as String? ?? "",
      lecturer: json['lecturer'] as String? ?? "",
    );

Map<String, dynamic> _$ChapelAttendanceInformationToJson(ChapelAttendanceInformation instance) => <String, dynamic>{
      'attendance': _$ChapelAttendanceEnumMap[instance.attendance]!,
      'overwrittenAttendance': _$ChapelAttendanceEnumMap[instance.overwrittenAttendance]!,
      'affiliation': instance.affiliation,
      'lectureDate': instance.lectureDate,
      'lectureEtc': instance.lectureEtc,
      'lectureName': instance.lectureName,
      'lectureType': instance.lectureType,
      'lecturer': instance.lecturer,
    };

const _$ChapelAttendanceEnumMap = {
  ChapelAttendance.unknown: 'unknown',
  ChapelAttendance.absent: 'absent',
  ChapelAttendance.attend: 'attend',
};
