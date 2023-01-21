// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SemesterSubjects.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SemesterSubjects _$SemesterSubjectsFromJson(Map<String, dynamic> json) => SemesterSubjects(
      (json['subjects'] as List<dynamic>).map((e) => Subject.fromJson(e as Map<String, dynamic>)).toList(),
      Ranking.fromJson(json['semesterRanking'] as Map<String, dynamic>),
      Ranking.fromJson(json['totalRanking'] as Map<String, dynamic>),
      YearSemester.fromJson(json['currentSemester'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SemesterSubjectsToJson(SemesterSubjects instance) => <String, dynamic>{
      'subjects': instance.subjects,
      'semesterRanking': instance.semesterRanking,
      'totalRanking': instance.totalRanking,
      'currentSemester': instance.currentSemester,
    };
