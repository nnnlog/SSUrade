// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'semester_subjects.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SemesterSubjectsCWProxy {
  SemesterSubjects subjects(SplayTreeMap<String, Subject> subjects);

  SemesterSubjects semesterRanking(Ranking semesterRanking);

  SemesterSubjects totalRanking(Ranking totalRanking);

  SemesterSubjects currentSemester(YearSemester currentSemester);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SemesterSubjects(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SemesterSubjects(...).copyWith(id: 12, name: "My name")
  /// ````
  SemesterSubjects call({
    SplayTreeMap<String, Subject>? subjects,
    Ranking? semesterRanking,
    Ranking? totalRanking,
    YearSemester? currentSemester,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSemesterSubjects.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSemesterSubjects.copyWith.fieldName(...)`
class _$SemesterSubjectsCWProxyImpl implements _$SemesterSubjectsCWProxy {
  const _$SemesterSubjectsCWProxyImpl(this._value);

  final SemesterSubjects _value;

  @override
  SemesterSubjects subjects(SplayTreeMap<String, Subject> subjects) =>
      this(subjects: subjects);

  @override
  SemesterSubjects semesterRanking(Ranking semesterRanking) =>
      this(semesterRanking: semesterRanking);

  @override
  SemesterSubjects totalRanking(Ranking totalRanking) =>
      this(totalRanking: totalRanking);

  @override
  SemesterSubjects currentSemester(YearSemester currentSemester) =>
      this(currentSemester: currentSemester);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SemesterSubjects(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SemesterSubjects(...).copyWith(id: 12, name: "My name")
  /// ````
  SemesterSubjects call({
    Object? subjects = const $CopyWithPlaceholder(),
    Object? semesterRanking = const $CopyWithPlaceholder(),
    Object? totalRanking = const $CopyWithPlaceholder(),
    Object? currentSemester = const $CopyWithPlaceholder(),
  }) {
    return SemesterSubjects(
      subjects: subjects == const $CopyWithPlaceholder() || subjects == null
          ? _value.subjects
          // ignore: cast_nullable_to_non_nullable
          : subjects as SplayTreeMap<String, Subject>,
      semesterRanking: semesterRanking == const $CopyWithPlaceholder() ||
              semesterRanking == null
          ? _value.semesterRanking
          // ignore: cast_nullable_to_non_nullable
          : semesterRanking as Ranking,
      totalRanking:
          totalRanking == const $CopyWithPlaceholder() || totalRanking == null
              ? _value.totalRanking
              // ignore: cast_nullable_to_non_nullable
              : totalRanking as Ranking,
      currentSemester: currentSemester == const $CopyWithPlaceholder() ||
              currentSemester == null
          ? _value.currentSemester
          // ignore: cast_nullable_to_non_nullable
          : currentSemester as YearSemester,
    );
  }
}

extension $SemesterSubjectsCopyWith on SemesterSubjects {
  /// Returns a callable class that can be used as follows: `instanceOfSemesterSubjects.copyWith(...)` or like so:`instanceOfSemesterSubjects.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SemesterSubjectsCWProxy get copyWith => _$SemesterSubjectsCWProxyImpl(this);
}

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
