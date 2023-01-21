// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'YearSemester.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

YearSemester _$YearSemesterFromJson(Map<String, dynamic> json) => YearSemester(
      json['year'] as int,
      $enumDecode(_$SemesterEnumMap, json['semester']),
    );

Map<String, dynamic> _$YearSemesterToJson(YearSemester instance) => <String, dynamic>{
      'year': instance.year,
      'semester': _$SemesterEnumMap[instance.semester]!,
    };

const _$SemesterEnumMap = {
  Semester.first: 'first',
  Semester.summer: 'summer',
  Semester.second: 'second',
  Semester.winter: 'winter',
};
