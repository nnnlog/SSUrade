// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Setting _$SettingFromJson(Map<String, dynamic> json) => Setting(
      refreshGradeAutomatically: json['refreshGradeAutomatically'] as bool,
      noticeGradeInBackground: json['noticeGradeInBackground'] as bool,
      showGrade: json['showGrade'] as bool,
      interval: (json['interval'] as num).toInt(),
      timeoutGrade: (json['timeoutGrade'] as num).toInt(),
      timeoutAllGrade: (json['timeoutAllGrade'] as num).toInt(),
      agree: json['agree'] as bool,
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
