// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'semester_subjects.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SemesterSubjects _$SemesterSubjectsFromJson(Map<String, dynamic> json) =>
    SemesterSubjects(
      subjects: const _DataConverter().fromJson(json['subjects'] as List),
      semesterRanking:
          Ranking.fromJson(json['semesterRanking'] as Map<String, dynamic>),
      totalRanking:
          Ranking.fromJson(json['totalRanking'] as Map<String, dynamic>),
      currentSemester: YearSemester.fromJson(
          json['currentSemester'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SemesterSubjectsToJson(SemesterSubjects instance) =>
    <String, dynamic>{
      'subjects': const _DataConverter().toJson(instance.subjects),
      'semesterRanking': instance.semesterRanking,
      'totalRanking': instance.totalRanking,
      'currentSemester': instance.currentSemester,
    };
