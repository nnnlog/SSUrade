// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapel_information.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChapelInformation _$ChapelInformationFromJson(Map<String, dynamic> json) => ChapelInformation(
      YearSemester.fromJson(json['currentSemester'] as Map<String, dynamic>),
      const _DataConverter().fromJson(json['attendances'] as List),
      json['subjectCode'] as String? ?? "",
      json['subjectPlace'] as String? ?? "",
      json['subjectTime'] as String? ?? "",
      json['floor'] as String? ?? "",
      json['seatNo'] as String? ?? "",
    );

Map<String, dynamic> _$ChapelInformationToJson(ChapelInformation instance) => <String, dynamic>{
      'currentSemester': instance.currentSemester,
      'attendances': const _DataConverter().toJson(instance.attendances),
      'subjectCode': instance.subjectCode,
      'subjectPlace': instance.subjectPlace,
      'subjectTime': instance.subjectTime,
      'floor': instance.floor,
      'seatNo': instance.seatNo,
    };
