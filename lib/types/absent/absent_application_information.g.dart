// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'absent_application_information.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AbsentApplicationInformation _$AbsentApplicationInformationFromJson(Map<String, dynamic> json) => AbsentApplicationInformation(
      json['absentType'] as String,
      json['startDate'] as String,
      json['endDate'] as String,
      json['absentCause'] as String,
      json['applicationDate'] as String,
      json['proceedDate'] as String,
      json['rejectCause'] as String,
      json['status'] as String,
    );

Map<String, dynamic> _$AbsentApplicationInformationToJson(AbsentApplicationInformation instance) => <String, dynamic>{
      'absentType': instance.absentType,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'absentCause': instance.absentCause,
      'applicationDate': instance.applicationDate,
      'proceedDate': instance.proceedDate,
      'rejectCause': instance.rejectCause,
      'status': instance.status,
    };
