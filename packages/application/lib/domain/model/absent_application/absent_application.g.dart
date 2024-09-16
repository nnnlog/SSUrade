// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'absent_application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AbsentApplication _$AbsentApplicationFromJson(Map<String, dynamic> json) =>
    AbsentApplication(
      absentType: json['absentType'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      absentCause: json['absentCause'] as String,
      applicationDate: json['applicationDate'] as String,
      proceedDate: json['proceedDate'] as String,
      rejectCause: json['rejectCause'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$AbsentApplicationToJson(AbsentApplication instance) =>
    <String, dynamic>{
      'absentType': instance.absentType,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'absentCause': instance.absentCause,
      'applicationDate': instance.applicationDate,
      'proceedDate': instance.proceedDate,
      'rejectCause': instance.rejectCause,
      'status': instance.status,
    };
