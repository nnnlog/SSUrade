// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SettingCWProxy {
  Setting refreshGradeAutomatically(bool refreshGradeAutomatically);

  Setting noticeGradeInBackground(bool noticeGradeInBackground);

  Setting showGrade(bool showGrade);

  Setting interval(int interval);

  Setting agree(bool agree);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Setting(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Setting(...).copyWith(id: 12, name: "My name")
  /// ````
  Setting call({
    bool? refreshGradeAutomatically,
    bool? noticeGradeInBackground,
    bool? showGrade,
    int? interval,
    bool? agree,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSetting.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSetting.copyWith.fieldName(...)`
class _$SettingCWProxyImpl implements _$SettingCWProxy {
  const _$SettingCWProxyImpl(this._value);

  final Setting _value;

  @override
  Setting refreshGradeAutomatically(bool refreshGradeAutomatically) =>
      this(refreshGradeAutomatically: refreshGradeAutomatically);

  @override
  Setting noticeGradeInBackground(bool noticeGradeInBackground) =>
      this(noticeGradeInBackground: noticeGradeInBackground);

  @override
  Setting showGrade(bool showGrade) => this(showGrade: showGrade);

  @override
  Setting interval(int interval) => this(interval: interval);

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
    Object? refreshGradeAutomatically = const $CopyWithPlaceholder(),
    Object? noticeGradeInBackground = const $CopyWithPlaceholder(),
    Object? showGrade = const $CopyWithPlaceholder(),
    Object? interval = const $CopyWithPlaceholder(),
    Object? agree = const $CopyWithPlaceholder(),
  }) {
    return Setting(
      refreshGradeAutomatically:
          refreshGradeAutomatically == const $CopyWithPlaceholder() ||
                  refreshGradeAutomatically == null
              ? _value.refreshGradeAutomatically
              // ignore: cast_nullable_to_non_nullable
              : refreshGradeAutomatically as bool,
      noticeGradeInBackground:
          noticeGradeInBackground == const $CopyWithPlaceholder() ||
                  noticeGradeInBackground == null
              ? _value.noticeGradeInBackground
              // ignore: cast_nullable_to_non_nullable
              : noticeGradeInBackground as bool,
      showGrade: showGrade == const $CopyWithPlaceholder() || showGrade == null
          ? _value.showGrade
          // ignore: cast_nullable_to_non_nullable
          : showGrade as bool,
      interval: interval == const $CopyWithPlaceholder() || interval == null
          ? _value.interval
          // ignore: cast_nullable_to_non_nullable
          : interval as int,
      agree: agree == const $CopyWithPlaceholder() || agree == null
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
      refreshGradeAutomatically: json['refreshGradeAutomatically'] as bool,
      noticeGradeInBackground: json['noticeGradeInBackground'] as bool,
      showGrade: json['showGrade'] as bool,
      interval: (json['interval'] as num).toInt(),
      agree: json['agree'] as bool,
    );

Map<String, dynamic> _$SettingToJson(Setting instance) => <String, dynamic>{
      'refreshGradeAutomatically': instance.refreshGradeAutomatically,
      'noticeGradeInBackground': instance.noticeGradeInBackground,
      'showGrade': instance.showGrade,
      'interval': instance.interval,
      'agree': instance.agree,
    };
