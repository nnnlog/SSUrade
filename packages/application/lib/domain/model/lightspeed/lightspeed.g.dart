// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lightspeed.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LightspeedCWProxy {
  Lightspeed version(String version);

  Lightspeed data(String data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Lightspeed(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Lightspeed(...).copyWith(id: 12, name: "My name")
  /// ````
  Lightspeed call({
    String? version,
    String? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLightspeed.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLightspeed.copyWith.fieldName(...)`
class _$LightspeedCWProxyImpl implements _$LightspeedCWProxy {
  const _$LightspeedCWProxyImpl(this._value);

  final Lightspeed _value;

  @override
  Lightspeed version(String version) => this(version: version);

  @override
  Lightspeed data(String data) => this(data: data);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Lightspeed(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Lightspeed(...).copyWith(id: 12, name: "My name")
  /// ````
  Lightspeed call({
    Object? version = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return Lightspeed(
      version: version == const $CopyWithPlaceholder() || version == null
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as String,
      data: data == const $CopyWithPlaceholder() || data == null
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as String,
    );
  }
}

extension $LightspeedCopyWith on Lightspeed {
  /// Returns a callable class that can be used as follows: `instanceOfLightspeed.copyWith(...)` or like so:`instanceOfLightspeed.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LightspeedCWProxy get copyWith => _$LightspeedCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lightspeed _$LightspeedFromJson(Map<String, dynamic> json) => Lightspeed(
      version: json['version'] as String,
      data: json['data'] as String,
    );

Map<String, dynamic> _$LightspeedToJson(Lightspeed instance) => <String, dynamic>{
      'version': instance.version,
      'data': instance.data,
    };
