// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Setting _$SettingFromJson(Map<String, dynamic> json) => Setting(
      json['refreshGradeAutomatically'] as bool,
      json['noticeGradeInBackground'] as bool,
      json['showGrade'] as bool,
      json['timeoutGrade'] as int,
      json['timeoutAllGrade'] as int,
      json['agree'] as bool,
    );

Map<String, dynamic> _$SettingToJson(Setting instance) => <String, dynamic>{
      'refreshGradeAutomatically': instance.refreshGradeAutomatically,
      'noticeGradeInBackground': instance.noticeGradeInBackground,
      'showGrade': instance.showGrade,
      'timeoutGrade': instance.timeoutGrade,
      'timeoutAllGrade': instance.timeoutAllGrade,
      'agree': instance.agree,
    };
