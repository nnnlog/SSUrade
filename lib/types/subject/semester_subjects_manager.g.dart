// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'semester_subjects_manager.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SemesterSubjectsManager _$SemesterSubjectsManagerFromJson(Map<String, dynamic> json) => SemesterSubjectsManager(
      const _DataConverter().fromJson(json['data'] as List),
      json['_state'] as int,
    );

Map<String, dynamic> _$SemesterSubjectsManagerToJson(SemesterSubjectsManager instance) => <String, dynamic>{
      '_state': instance._state,
      'data': const _DataConverter().toJson(instance.data),
    };
