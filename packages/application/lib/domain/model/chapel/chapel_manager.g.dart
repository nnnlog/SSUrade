// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapel_manager.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChapelManagerCWProxy {
  ChapelManager data(SplayTreeMap<YearSemester, Chapel> data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChapelManager(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChapelManager(...).copyWith(id: 12, name: "My name")
  /// ````
  ChapelManager call({
    SplayTreeMap<YearSemester, Chapel>? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfChapelManager.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfChapelManager.copyWith.fieldName(...)`
class _$ChapelManagerCWProxyImpl implements _$ChapelManagerCWProxy {
  const _$ChapelManagerCWProxyImpl(this._value);

  final ChapelManager _value;

  @override
  ChapelManager data(SplayTreeMap<YearSemester, Chapel> data) => this(data: data);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChapelManager(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChapelManager(...).copyWith(id: 12, name: "My name")
  /// ````
  ChapelManager call({
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ChapelManager(
      data == const $CopyWithPlaceholder() || data == null
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as SplayTreeMap<YearSemester, Chapel>,
    );
  }
}

extension $ChapelManagerCopyWith on ChapelManager {
  /// Returns a callable class that can be used as follows: `instanceOfChapelManager.copyWith(...)` or like so:`instanceOfChapelManager.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ChapelManagerCWProxy get copyWith => _$ChapelManagerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChapelManager _$ChapelManagerFromJson(Map<String, dynamic> json) => ChapelManager(
      const _DataConverter().fromJson(json['data'] as List),
    );

Map<String, dynamic> _$ChapelManagerToJson(ChapelManager instance) => <String, dynamic>{
      'data': const _DataConverter().toJson(instance.data),
    };
