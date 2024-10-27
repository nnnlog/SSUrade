// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_bloc.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GradeShowingCWProxy {
  GradeShowing semesterSubjectsManager(SemesterSubjectsManager semesterSubjectsManager);

  GradeShowing showingSemester(YearSemester showingSemester);

  GradeShowing isExporting(bool isExporting);

  GradeShowing isDisplayRankingDuringExporting(bool isDisplayRankingDuringExporting);

  GradeShowing isDisplaySubjectInformationDuringExporting(bool isDisplaySubjectInformationDuringExporting);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GradeShowing(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GradeShowing(...).copyWith(id: 12, name: "My name")
  /// ````
  GradeShowing call({
    SemesterSubjectsManager? semesterSubjectsManager,
    YearSemester? showingSemester,
    bool? isExporting,
    bool? isDisplayRankingDuringExporting,
    bool? isDisplaySubjectInformationDuringExporting,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGradeShowing.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGradeShowing.copyWith.fieldName(...)`
class _$GradeShowingCWProxyImpl implements _$GradeShowingCWProxy {
  const _$GradeShowingCWProxyImpl(this._value);

  final GradeShowing _value;

  @override
  GradeShowing semesterSubjectsManager(SemesterSubjectsManager semesterSubjectsManager) => this(semesterSubjectsManager: semesterSubjectsManager);

  @override
  GradeShowing showingSemester(YearSemester showingSemester) => this(showingSemester: showingSemester);

  @override
  GradeShowing isExporting(bool isExporting) => this(isExporting: isExporting);

  @override
  GradeShowing isDisplayRankingDuringExporting(bool isDisplayRankingDuringExporting) => this(isDisplayRankingDuringExporting: isDisplayRankingDuringExporting);

  @override
  GradeShowing isDisplaySubjectInformationDuringExporting(bool isDisplaySubjectInformationDuringExporting) =>
      this(isDisplaySubjectInformationDuringExporting: isDisplaySubjectInformationDuringExporting);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GradeShowing(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GradeShowing(...).copyWith(id: 12, name: "My name")
  /// ````
  GradeShowing call({
    Object? semesterSubjectsManager = const $CopyWithPlaceholder(),
    Object? showingSemester = const $CopyWithPlaceholder(),
    Object? isExporting = const $CopyWithPlaceholder(),
    Object? isDisplayRankingDuringExporting = const $CopyWithPlaceholder(),
    Object? isDisplaySubjectInformationDuringExporting = const $CopyWithPlaceholder(),
  }) {
    return GradeShowing(
      semesterSubjectsManager: semesterSubjectsManager == const $CopyWithPlaceholder() || semesterSubjectsManager == null
          ? _value.semesterSubjectsManager
          // ignore: cast_nullable_to_non_nullable
          : semesterSubjectsManager as SemesterSubjectsManager,
      showingSemester: showingSemester == const $CopyWithPlaceholder() || showingSemester == null
          ? _value.showingSemester
          // ignore: cast_nullable_to_non_nullable
          : showingSemester as YearSemester,
      isExporting: isExporting == const $CopyWithPlaceholder() || isExporting == null
          ? _value.isExporting
          // ignore: cast_nullable_to_non_nullable
          : isExporting as bool,
      isDisplayRankingDuringExporting: isDisplayRankingDuringExporting == const $CopyWithPlaceholder() || isDisplayRankingDuringExporting == null
          ? _value.isDisplayRankingDuringExporting
          // ignore: cast_nullable_to_non_nullable
          : isDisplayRankingDuringExporting as bool,
      isDisplaySubjectInformationDuringExporting: isDisplaySubjectInformationDuringExporting == const $CopyWithPlaceholder() || isDisplaySubjectInformationDuringExporting == null
          ? _value.isDisplaySubjectInformationDuringExporting
          // ignore: cast_nullable_to_non_nullable
          : isDisplaySubjectInformationDuringExporting as bool,
    );
  }
}

extension $GradeShowingCopyWith on GradeShowing {
  /// Returns a callable class that can be used as follows: `instanceOfGradeShowing.copyWith(...)` or like so:`instanceOfGradeShowing.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GradeShowingCWProxy get copyWith => _$GradeShowingCWProxyImpl(this);
}
