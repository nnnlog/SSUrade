// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'absent_application_manager.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AbsentApplicationManager _$AbsentApplicationManagerFromJson(
        Map<String, dynamic> json) =>
    AbsentApplicationManager(
      (json['data'] as List<dynamic>)
          .map((e) => AbsentApplication.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AbsentApplicationManagerToJson(
        AbsentApplicationManager instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
