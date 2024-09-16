// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'semester_subjects_manager.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SemesterSubjectsManager _$SemesterSubjectsManagerFromJson(
        Map<String, dynamic> json) =>
    SemesterSubjectsManager(
      data: const _DataConverter().fromJson(json['data'] as List),
      state: (json['state'] as num).toInt(),
    );

Map<String, dynamic> _$SemesterSubjectsManagerToJson(
        SemesterSubjectsManager instance) =>
    <String, dynamic>{
      'state': instance.state,
      'data': const _DataConverter().toJson(instance.data),
    };
