// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ChapelAttendanceInformation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChapelAttendanceInformation _$ChapelAttendanceInformationFromJson(Map<String, dynamic> json) => ChapelAttendanceInformation(
      $enumDecode(_$ChapelAttendanceEnumMap, json['attendance']),
      $enumDecode(_$ChapelAttendanceEnumMap, json['overwrittenAttendance']),
      json['lectureDate'] as String,
      json['lectureEtc'] as String,
      json['lectureName'] as String,
      json['lectureType'] as String,
      json['lecturer'] as String,
    );

Map<String, dynamic> _$ChapelAttendanceInformationToJson(ChapelAttendanceInformation instance) => <String, dynamic>{
      'attendance': _$ChapelAttendanceEnumMap[instance.attendance]!,
      'overwrittenAttendance': _$ChapelAttendanceEnumMap[instance.overwrittenAttendance]!,
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
