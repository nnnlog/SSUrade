// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AppVersionCWProxy {
  AppVersion appVersion(String appVersion);

  AppVersion newVersion(String newVersion);

  AppVersion devVersion(String devVersion);

  AppVersion buildNumber(String buildNumber);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AppVersion(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AppVersion(...).copyWith(id: 12, name: "My name")
  /// ````
  AppVersion call({
    String appVersion,
    String newVersion,
    String devVersion,
    String buildNumber,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAppVersion.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAppVersion.copyWith.fieldName(...)`
class _$AppVersionCWProxyImpl implements _$AppVersionCWProxy {
  const _$AppVersionCWProxyImpl(this._value);

  final AppVersion _value;

  @override
  AppVersion appVersion(String appVersion) => this(appVersion: appVersion);

  @override
  AppVersion newVersion(String newVersion) => this(newVersion: newVersion);

  @override
  AppVersion devVersion(String devVersion) => this(devVersion: devVersion);

  @override
  AppVersion buildNumber(String buildNumber) => this(buildNumber: buildNumber);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AppVersion(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AppVersion(...).copyWith(id: 12, name: "My name")
  /// ````
  AppVersion call({
    Object? appVersion = const $CopyWithPlaceholder(),
    Object? newVersion = const $CopyWithPlaceholder(),
    Object? devVersion = const $CopyWithPlaceholder(),
    Object? buildNumber = const $CopyWithPlaceholder(),
  }) {
    return AppVersion(
      appVersion: appVersion == const $CopyWithPlaceholder()
          ? _value.appVersion
          // ignore: cast_nullable_to_non_nullable
          : appVersion as String,
      newVersion: newVersion == const $CopyWithPlaceholder()
          ? _value.newVersion
          // ignore: cast_nullable_to_non_nullable
          : newVersion as String,
      devVersion: devVersion == const $CopyWithPlaceholder()
          ? _value.devVersion
          // ignore: cast_nullable_to_non_nullable
          : devVersion as String,
      buildNumber: buildNumber == const $CopyWithPlaceholder()
          ? _value.buildNumber
          // ignore: cast_nullable_to_non_nullable
          : buildNumber as String,
    );
  }
}

extension $AppVersionCopyWith on AppVersion {
  /// Returns a callable class that can be used as follows: `instanceOfAppVersion.copyWith(...)` or like so:`instanceOfAppVersion.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AppVersionCWProxy get copyWith => _$AppVersionCWProxyImpl(this);
}
