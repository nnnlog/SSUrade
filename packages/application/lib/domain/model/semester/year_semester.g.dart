// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'year_semester.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$YearSemesterCWProxy {
  YearSemester year(int year);

  YearSemester semester(Semester semester);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `YearSemester(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// YearSemester(...).copyWith(id: 12, name: "My name")
  /// ````
  YearSemester call({
    int? year,
    Semester? semester,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfYearSemester.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfYearSemester.copyWith.fieldName(...)`
class _$YearSemesterCWProxyImpl implements _$YearSemesterCWProxy {
  const _$YearSemesterCWProxyImpl(this._value);

  final YearSemester _value;

  @override
  YearSemester year(int year) => this(year: year);

  @override
  YearSemester semester(Semester semester) => this(semester: semester);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `YearSemester(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// YearSemester(...).copyWith(id: 12, name: "My name")
  /// ````
  YearSemester call({
    Object? year = const $CopyWithPlaceholder(),
    Object? semester = const $CopyWithPlaceholder(),
  }) {
    return YearSemester(
      year: year == const $CopyWithPlaceholder() || year == null
          ? _value.year
          // ignore: cast_nullable_to_non_nullable
          : year as int,
      semester: semester == const $CopyWithPlaceholder() || semester == null
          ? _value.semester
          // ignore: cast_nullable_to_non_nullable
          : semester as Semester,
    );
  }
}

extension $YearSemesterCopyWith on YearSemester {
  /// Returns a callable class that can be used as follows: `instanceOfYearSemester.copyWith(...)` or like so:`instanceOfYearSemester.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$YearSemesterCWProxy get copyWith => _$YearSemesterCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

YearSemester _$YearSemesterFromJson(Map<String, dynamic> json) => YearSemester(
      year: (json['year'] as num).toInt(),
      semester: $enumDecode(_$SemesterEnumMap, json['semester']),
    );

Map<String, dynamic> _$YearSemesterToJson(YearSemester instance) =>
    <String, dynamic>{
      'year': instance.year,
      'semester': _$SemesterEnumMap[instance.semester]!,
    };

const _$SemesterEnumMap = {
  Semester.first: 'first',
  Semester.summer: 'summer',
  Semester.second: 'second',
  Semester.winter: 'winter',
};
