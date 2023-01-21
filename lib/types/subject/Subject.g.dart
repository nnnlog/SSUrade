// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subject _$SubjectFromJson(Map<String, dynamic> json) => Subject(
      json['code'] as String,
      json['name'] as String,
      (json['credit'] as num).toDouble(),
      json['grade'] as String,
      json['professor'] as String,
    );

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'credit': instance.credit,
      'grade': instance.grade,
      'professor': instance.professor,
    };
