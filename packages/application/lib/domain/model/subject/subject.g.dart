// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subject _$SubjectFromJson(Map<String, dynamic> json) => Subject(
      code: json['code'] as String,
      name: json['name'] as String,
      credit: (json['credit'] as num).toDouble(),
      grade: json['grade'] as String,
      score: json['score'] as String,
      professor: json['professor'] as String,
      category: json['category'] as String,
      isPassFail: json['isPassFail'] as bool,
      info: json['info'] as String,
      detail: Map<String, String>.from(json['detail'] as Map),
    );

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
      'code': instance.code,
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
