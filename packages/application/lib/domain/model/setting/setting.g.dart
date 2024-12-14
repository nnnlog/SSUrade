// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SettingCWProxy {
  Setting refreshInformationAutomatically(bool refreshInformationAutomatically);

  Setting enableBackgroundFeature(bool enableBackgroundFeature);

  Setting showGradeInBackground(bool showGradeInBackground);

  Setting backgroundInterval(int backgroundInterval);

  Setting agree(bool agree);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Setting(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Setting(...).copyWith(id: 12, name: "My name")
  /// ````
  Setting call({
    bool refreshInformationAutomatically,
    bool enableBackgroundFeature,
    bool showGradeInBackground,
    int backgroundInterval,
    bool agree,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSetting.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSetting.copyWith.fieldName(...)`
class _$SettingCWProxyImpl implements _$SettingCWProxy {
  const _$SettingCWProxyImpl(this._value);

  final Setting _value;

  @override
  Setting refreshInformationAutomatically(bool refreshInformationAutomatically) => this(refreshInformationAutomatically: refreshInformationAutomatically);

  @override
  Setting enableBackgroundFeature(bool enableBackgroundFeature) => this(enableBackgroundFeature: enableBackgroundFeature);

  @override
  Setting showGradeInBackground(bool showGradeInBackground) => this(showGradeInBackground: showGradeInBackground);

  @override
  Setting backgroundInterval(int backgroundInterval) => this(backgroundInterval: backgroundInterval);

  @override
  Setting agree(bool agree) => this(agree: agree);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Setting(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Setting(...).copyWith(id: 12, name: "My name")
  /// ````
  Setting call({
    Object? refreshInformationAutomatically = const $CopyWithPlaceholder(),
    Object? enableBackgroundFeature = const $CopyWithPlaceholder(),
    Object? showGradeInBackground = const $CopyWithPlaceholder(),
    Object? backgroundInterval = const $CopyWithPlaceholder(),
    Object? agree = const $CopyWithPlaceholder(),
  }) {
    return Setting(
      refreshInformationAutomatically: refreshInformationAutomatically == const $CopyWithPlaceholder()
          ? _value.refreshInformationAutomatically
          // ignore: cast_nullable_to_non_nullable
          : refreshInformationAutomatically as bool,
      enableBackgroundFeature: enableBackgroundFeature == const $CopyWithPlaceholder()
          ? _value.enableBackgroundFeature
          // ignore: cast_nullable_to_non_nullable
          : enableBackgroundFeature as bool,
      showGradeInBackground: showGradeInBackground == const $CopyWithPlaceholder()
          ? _value.showGradeInBackground
          // ignore: cast_nullable_to_non_nullable
          : showGradeInBackground as bool,
      backgroundInterval: backgroundInterval == const $CopyWithPlaceholder()
          ? _value.backgroundInterval
          // ignore: cast_nullable_to_non_nullable
          : backgroundInterval as int,
      agree: agree == const $CopyWithPlaceholder()
          ? _value.agree
          // ignore: cast_nullable_to_non_nullable
          : agree as bool,
    );
  }
}

extension $SettingCopyWith on Setting {
  /// Returns a callable class that can be used as follows: `instanceOfSetting.copyWith(...)` or like so:`instanceOfSetting.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SettingCWProxy get copyWith => _$SettingCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Setting _$SettingFromJson(Map<String, dynamic> json) => Setting(
      refreshInformationAutomatically: json['refreshInformationAutomatically'] as bool,
      enableBackgroundFeature: json['enableBackgroundFeature'] as bool,
      showGradeInBackground: json['showGradeInBackground'] as bool,
      backgroundInterval: (json['backgroundInterval'] as num).toInt(),
      agree: json['agree'] as bool,
    );

Map<String, dynamic> _$SettingToJson(Setting instance) => <String, dynamic>{
      'refreshInformationAutomatically': instance.refreshInformationAutomatically,
      'enableBackgroundFeature': instance.enableBackgroundFeature,
      'showGradeInBackground': instance.showGradeInBackground,
      'backgroundInterval': instance.backgroundInterval,
      'agree': instance.agree,
    };
