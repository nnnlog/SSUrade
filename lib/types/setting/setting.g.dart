// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Setting _$SettingFromJson(Map<String, dynamic> json) => Setting(
      json['refreshGradeAutomatically'] as bool,
      json['noticeGradeInBackground'] as bool,
      json['showGrade'] as bool,
      (json['interval'] as num).toInt(),
      (json['timeoutGrade'] as num).toInt(),
      (json['timeoutAllGrade'] as num).toInt(),
      json['agree'] as bool,
    );

Map<String, dynamic> _$SettingToJson(Setting instance) => <String, dynamic>{
      'refreshGradeAutomatically': instance.refreshGradeAutomatically,
      'noticeGradeInBackground': instance.noticeGradeInBackground,
      'showGrade': instance.showGrade,
      'interval': instance.interval,
      'timeoutGrade': instance.timeoutGrade,
      'timeoutAllGrade': instance.timeoutAllGrade,
      'agree': instance.agree,
    };
