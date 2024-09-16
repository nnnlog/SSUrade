// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scholarship_manager.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ScholarshipManagerCWProxy {
  ScholarshipManager data(List<Scholarship> data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ScholarshipManager(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ScholarshipManager(...).copyWith(id: 12, name: "My name")
  /// ````
  ScholarshipManager call({
    List<Scholarship>? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfScholarshipManager.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfScholarshipManager.copyWith.fieldName(...)`
class _$ScholarshipManagerCWProxyImpl implements _$ScholarshipManagerCWProxy {
  const _$ScholarshipManagerCWProxyImpl(this._value);

  final ScholarshipManager _value;

  @override
  ScholarshipManager data(List<Scholarship> data) => this(data: data);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ScholarshipManager(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ScholarshipManager(...).copyWith(id: 12, name: "My name")
  /// ````
  ScholarshipManager call({
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ScholarshipManager(
      data == const $CopyWithPlaceholder() || data == null
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<Scholarship>,
    );
  }
}

extension $ScholarshipManagerCopyWith on ScholarshipManager {
  /// Returns a callable class that can be used as follows: `instanceOfScholarshipManager.copyWith(...)` or like so:`instanceOfScholarshipManager.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ScholarshipManagerCWProxy get copyWith =>
      _$ScholarshipManagerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScholarshipManager _$ScholarshipManagerFromJson(Map<String, dynamic> json) =>
    ScholarshipManager(
      (json['data'] as List<dynamic>)
          .map((e) => Scholarship.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ScholarshipManagerToJson(ScholarshipManager instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
