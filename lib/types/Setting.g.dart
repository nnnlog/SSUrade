// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Setting _$SettingFromJson(Map<String, dynamic> json) => Setting(
      USaintSession.fromJson(json['uSaintSession'] as Map<String, dynamic>),
      json['refreshGradeAutomatically'] as bool,
      json['timeoutGrade'] as int,
      json['timeoutAllGrade'] as int,
    );

Map<String, dynamic> _$SettingToJson(Setting instance) => <String, dynamic>{
      'uSaintSession': instance.uSaintSession,
      'refreshGradeAutomatically': instance.refreshGradeAutomatically,
      'timeoutGrade': instance.timeoutGrade,
      'timeoutAllGrade': instance.timeoutAllGrade,
    };
