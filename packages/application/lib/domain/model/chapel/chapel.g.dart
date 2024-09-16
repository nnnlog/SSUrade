// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chapel _$ChapelFromJson(Map<String, dynamic> json) => Chapel(
      YearSemester.fromJson(json['currentSemester'] as Map<String, dynamic>),
      const _DataConverter().fromJson(json['attendances'] as List),
      subjectCode: json['subjectCode'] as String? ?? "",
      subjectPlace: json['subjectPlace'] as String? ?? "",
      subjectTime: json['subjectTime'] as String? ?? "",
      floor: json['floor'] as String? ?? "",
      seatNo: json['seatNo'] as String? ?? "",
    );

Map<String, dynamic> _$ChapelToJson(Chapel instance) => <String, dynamic>{
      'currentSemester': instance.currentSemester,
      'attendances': const _DataConverter().toJson(instance.attendances),
      'subjectCode': instance.subjectCode,
      'subjectPlace': instance.subjectPlace,
      'subjectTime': instance.subjectTime,
      'floor': instance.floor,
      'seatNo': instance.seatNo,
    };
