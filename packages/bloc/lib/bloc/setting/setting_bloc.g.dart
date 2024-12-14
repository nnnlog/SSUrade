// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_bloc.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SettingShowingCWProxy {
  SettingShowing setting(Setting setting);

  SettingShowing isLogined(bool isLogined);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SettingShowing(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SettingShowing(...).copyWith(id: 12, name: "My name")
  /// ````
  SettingShowing call({
    Setting setting,
    bool isLogined,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSettingShowing.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSettingShowing.copyWith.fieldName(...)`
class _$SettingShowingCWProxyImpl implements _$SettingShowingCWProxy {
  const _$SettingShowingCWProxyImpl(this._value);

  final SettingShowing _value;

  @override
  SettingShowing setting(Setting setting) => this(setting: setting);

  @override
  SettingShowing isLogined(bool isLogined) => this(isLogined: isLogined);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SettingShowing(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SettingShowing(...).copyWith(id: 12, name: "My name")
  /// ````
  SettingShowing call({
    Object? setting = const $CopyWithPlaceholder(),
    Object? isLogined = const $CopyWithPlaceholder(),
  }) {
    return SettingShowing(
      setting == const $CopyWithPlaceholder()
          ? _value.setting
          // ignore: cast_nullable_to_non_nullable
          : setting as Setting,
      isLogined == const $CopyWithPlaceholder()
          ? _value.isLogined
          // ignore: cast_nullable_to_non_nullable
          : isLogined as bool,
    );
  }
}

extension $SettingShowingCopyWith on SettingShowing {
  /// Returns a callable class that can be used as follows: `instanceOfSettingShowing.copyWith(...)` or like so:`instanceOfSettingShowing.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SettingShowingCWProxy get copyWith => _$SettingShowingCWProxyImpl(this);
}
