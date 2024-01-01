// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'year_semester.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

YearSemester _$YearSemesterFromJson(Map<String, dynamic> json) => YearSemester(
      json['_year'] as int,
      $enumDecode(_$SemesterEnumMap, json['_semester']),
    );

Map<String, dynamic> _$YearSemesterToJson(YearSemester instance) => <String, dynamic>{
      '_year': instance._year,
      '_semester': _$SemesterEnumMap[instance._semester]!,
    };

const _$SemesterEnumMap = {
  Semester.first: 'first',
  Semester.summer: 'summer',
  Semester.second: 'second',
  Semester.winter: 'winter',
};
