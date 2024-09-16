// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scholarship.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Scholarship _$ScholarshipFromJson(Map<String, dynamic> json) => Scholarship(
      when: YearSemester.fromJson(json['when'] as Map<String, dynamic>),
      name: json['name'] as String,
      process: json['process'] as String,
      price: json['price'] as String,
    );

Map<String, dynamic> _$ScholarshipToJson(Scholarship instance) =>
    <String, dynamic>{
      'when': instance.when,
      'name': instance.name,
      'process': instance.process,
      'price': instance.price,
    };
