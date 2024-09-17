// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_setting.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BackgroundSettingCWProxy {
  BackgroundSetting notificationId(int notificationId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BackgroundSetting(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BackgroundSetting(...).copyWith(id: 12, name: "My name")
  /// ````
  BackgroundSetting call({
    int? notificationId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBackgroundSetting.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBackgroundSetting.copyWith.fieldName(...)`
class _$BackgroundSettingCWProxyImpl implements _$BackgroundSettingCWProxy {
  const _$BackgroundSettingCWProxyImpl(this._value);

  final BackgroundSetting _value;

  @override
  BackgroundSetting notificationId(int notificationId) =>
      this(notificationId: notificationId);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BackgroundSetting(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BackgroundSetting(...).copyWith(id: 12, name: "My name")
  /// ````
  BackgroundSetting call({
    Object? notificationId = const $CopyWithPlaceholder(),
  }) {
    return BackgroundSetting(
      notificationId == const $CopyWithPlaceholder() || notificationId == null
          ? _value.notificationId
          // ignore: cast_nullable_to_non_nullable
          : notificationId as int,
    );
  }
}

extension $BackgroundSettingCopyWith on BackgroundSetting {
  /// Returns a callable class that can be used as follows: `instanceOfBackgroundSetting.copyWith(...)` or like so:`instanceOfBackgroundSetting.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BackgroundSettingCWProxy get copyWith =>
      _$BackgroundSettingCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackgroundSetting _$BackgroundSettingFromJson(Map<String, dynamic> json) =>
    BackgroundSetting(
      (json['notificationId'] as num).toInt(),
    );

Map<String, dynamic> _$BackgroundSettingToJson(BackgroundSetting instance) =>
    <String, dynamic>{
      'notificationId': instance.notificationId,
    };
