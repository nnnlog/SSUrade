// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subject _$SubjectFromJson(Map<String, dynamic> json) => Subject(
      json['_code'] as String,
      json['name'] as String,
      (json['credit'] as num).toDouble(),
      json['grade'] as String,
      json['score'] as String,
      json['professor'] as String,
      json['category'] as String,
      json['isPassFail'] as bool,
      json['info'] as String,
    )..detail = Map<String, String>.from(json['detail'] as Map);

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
      '_code': instance._code,
      'name': instance.name,
      'credit': instance.credit,
      'grade': instance.grade,
      'score': instance.score,
      'professor': instance.professor,
      'category': instance.category,
      'isPassFail': instance.isPassFail,
      'info': instance.info,
      'detail': instance.detail,
    };
