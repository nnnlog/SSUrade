// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'semester_subjects.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SemesterSubjects _$SemesterSubjectsFromJson(Map<String, dynamic> json) => SemesterSubjects(
      const _DataConverter().fromJson(json['subjects'] as List),
      json['currentSemester'] == null ? const YearSemester(0, Semester.first) : YearSemester.fromJson(json['currentSemester'] as Map<String, dynamic>),
      json['semesterRanking'] == null ? Ranking.unknown : Ranking.fromJson(json['semesterRanking'] as Map<String, dynamic>),
      json['totalRanking'] == null ? Ranking.unknown : Ranking.fromJson(json['totalRanking'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SemesterSubjectsToJson(SemesterSubjects instance) => <String, dynamic>{
      'subjects': const _DataConverter().toJson(instance.subjects),
      'semesterRanking': instance.semesterRanking,
      'totalRanking': instance.totalRanking,
      'currentSemester': instance.currentSemester,
    };
