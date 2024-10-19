// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'semester_subjects_manager.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SemesterSubjectsManagerCWProxy {
  SemesterSubjectsManager data(SplayTreeMap<YearSemester, SemesterSubjects> data);

  SemesterSubjectsManager state(int state);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SemesterSubjectsManager(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SemesterSubjectsManager(...).copyWith(id: 12, name: "My name")
  /// ````
  SemesterSubjectsManager call({
    SplayTreeMap<YearSemester, SemesterSubjects>? data,
    int? state,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSemesterSubjectsManager.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSemesterSubjectsManager.copyWith.fieldName(...)`
class _$SemesterSubjectsManagerCWProxyImpl implements _$SemesterSubjectsManagerCWProxy {
  const _$SemesterSubjectsManagerCWProxyImpl(this._value);

  final SemesterSubjectsManager _value;

  @override
  SemesterSubjectsManager data(SplayTreeMap<YearSemester, SemesterSubjects> data) => this(data: data);

  @override
  SemesterSubjectsManager state(int state) => this(state: state);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SemesterSubjectsManager(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SemesterSubjectsManager(...).copyWith(id: 12, name: "My name")
  /// ````
  SemesterSubjectsManager call({
    Object? data = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
  }) {
    return SemesterSubjectsManager(
      data: data == const $CopyWithPlaceholder() || data == null
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as SplayTreeMap<YearSemester, SemesterSubjects>,
      state: state == const $CopyWithPlaceholder() || state == null
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as int,
    );
  }
}

extension $SemesterSubjectsManagerCopyWith on SemesterSubjectsManager {
  /// Returns a callable class that can be used as follows: `instanceOfSemesterSubjectsManager.copyWith(...)` or like so:`instanceOfSemesterSubjectsManager.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SemesterSubjectsManagerCWProxy get copyWith => _$SemesterSubjectsManagerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SemesterSubjectsManager _$SemesterSubjectsManagerFromJson(Map<String, dynamic> json) => SemesterSubjectsManager(
      data: const _DataConverter().fromJson(json['data'] as List),
      state: (json['state'] as num).toInt(),
    );

Map<String, dynamic> _$SemesterSubjectsManagerToJson(SemesterSubjectsManager instance) => <String, dynamic>{
      'state': instance.state,
      'data': const _DataConverter().toJson(instance.data),
    };
