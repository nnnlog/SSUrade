// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subject _$SubjectFromJson(Map<String, dynamic> json) => Subject(
      json['_code'] as String,
      json['name'] as String,
      (json['credit'] as num).toDouble(),
      json['grade'] as String,
      json['professor'] as String,
      json['category'] as String,
      json['isPassFail'] as bool,
      json['_state'] as int,
    )..detail = Map<String, String>.from(json['detail'] as Map);

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
      '_code': instance._code,
      'name': instance.name,
      'credit': instance.credit,
      'grade': instance.grade,
      'professor': instance.professor,
      'category': instance.category,
      'isPassFail': instance.isPassFail,
      'detail': instance.detail,
      '_state': instance._state,
    };
