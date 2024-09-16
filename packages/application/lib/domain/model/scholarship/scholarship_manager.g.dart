// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scholarship_manager.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScholarshipManager _$ScholarshipManagerFromJson(Map<String, dynamic> json) =>
    ScholarshipManager(
      (json['data'] as List<dynamic>)
          .map((e) => Scholarship.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ScholarshipManagerToJson(ScholarshipManager instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
