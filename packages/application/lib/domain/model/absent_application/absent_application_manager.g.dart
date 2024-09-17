// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'absent_application_manager.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AbsentApplicationManagerCWProxy {
  AbsentApplicationManager data(List<AbsentApplication> data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AbsentApplicationManager(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AbsentApplicationManager(...).copyWith(id: 12, name: "My name")
  /// ````
  AbsentApplicationManager call({
    List<AbsentApplication>? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAbsentApplicationManager.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAbsentApplicationManager.copyWith.fieldName(...)`
class _$AbsentApplicationManagerCWProxyImpl implements _$AbsentApplicationManagerCWProxy {
  const _$AbsentApplicationManagerCWProxyImpl(this._value);

  final AbsentApplicationManager _value;

  @override
  AbsentApplicationManager data(List<AbsentApplication> data) => this(data: data);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AbsentApplicationManager(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AbsentApplicationManager(...).copyWith(id: 12, name: "My name")
  /// ````
  AbsentApplicationManager call({
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return AbsentApplicationManager(
      data == const $CopyWithPlaceholder() || data == null
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<AbsentApplication>,
    );
  }
}

extension $AbsentApplicationManagerCopyWith on AbsentApplicationManager {
  /// Returns a callable class that can be used as follows: `instanceOfAbsentApplicationManager.copyWith(...)` or like so:`instanceOfAbsentApplicationManager.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AbsentApplicationManagerCWProxy get copyWith => _$AbsentApplicationManagerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AbsentApplicationManager _$AbsentApplicationManagerFromJson(Map<String, dynamic> json) => AbsentApplicationManager(
      (json['data'] as List<dynamic>).map((e) => AbsentApplication.fromJson(e as Map<String, dynamic>)).toList(),
    );

Map<String, dynamic> _$AbsentApplicationManagerToJson(AbsentApplicationManager instance) => <String, dynamic>{
      'data': instance.data,
    };
