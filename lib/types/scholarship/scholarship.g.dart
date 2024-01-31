// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scholarship.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Scholarship _$ScholarshipFromJson(Map<String, dynamic> json) => Scholarship(
      YearSemester.fromJson(json['when'] as Map<String, dynamic>),
      json['name'] as String,
      json['process'] as String,
      json['price'] as String,
    );

Map<String, dynamic> _$ScholarshipToJson(Scholarship instance) => <String, dynamic>{
      'when': instance.when,
      'name': instance.name,
      'process': instance.process,
      'price': instance.price,
    };
