// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapel.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChapelCWProxy {
  Chapel currentSemester(YearSemester currentSemester);

  Chapel attendances(SplayTreeSet<ChapelAttendance> attendances);

  Chapel subjectCode(String subjectCode);

  Chapel subjectPlace(String subjectPlace);

  Chapel subjectTime(String subjectTime);

  Chapel floor(String floor);

  Chapel seatNo(String seatNo);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Chapel(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Chapel(...).copyWith(id: 12, name: "My name")
  /// ````
  Chapel call({
    YearSemester? currentSemester,
    SplayTreeSet<ChapelAttendance>? attendances,
    String? subjectCode,
    String? subjectPlace,
    String? subjectTime,
    String? floor,
    String? seatNo,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfChapel.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfChapel.copyWith.fieldName(...)`
class _$ChapelCWProxyImpl implements _$ChapelCWProxy {
  const _$ChapelCWProxyImpl(this._value);

  final Chapel _value;

  @override
  Chapel currentSemester(YearSemester currentSemester) =>
      this(currentSemester: currentSemester);

  @override
  Chapel attendances(SplayTreeSet<ChapelAttendance> attendances) =>
      this(attendances: attendances);

  @override
  Chapel subjectCode(String subjectCode) => this(subjectCode: subjectCode);

  @override
  Chapel subjectPlace(String subjectPlace) => this(subjectPlace: subjectPlace);

  @override
  Chapel subjectTime(String subjectTime) => this(subjectTime: subjectTime);

  @override
  Chapel floor(String floor) => this(floor: floor);

  @override
  Chapel seatNo(String seatNo) => this(seatNo: seatNo);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Chapel(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Chapel(...).copyWith(id: 12, name: "My name")
  /// ````
  Chapel call({
    Object? currentSemester = const $CopyWithPlaceholder(),
    Object? attendances = const $CopyWithPlaceholder(),
    Object? subjectCode = const $CopyWithPlaceholder(),
    Object? subjectPlace = const $CopyWithPlaceholder(),
    Object? subjectTime = const $CopyWithPlaceholder(),
    Object? floor = const $CopyWithPlaceholder(),
    Object? seatNo = const $CopyWithPlaceholder(),
  }) {
    return Chapel(
      currentSemester == const $CopyWithPlaceholder() || currentSemester == null
          ? _value.currentSemester
          // ignore: cast_nullable_to_non_nullable
          : currentSemester as YearSemester,
      attendances == const $CopyWithPlaceholder() || attendances == null
          ? _value.attendances
          // ignore: cast_nullable_to_non_nullable
          : attendances as SplayTreeSet<ChapelAttendance>,
      subjectCode:
          subjectCode == const $CopyWithPlaceholder() || subjectCode == null
              ? _value.subjectCode
              // ignore: cast_nullable_to_non_nullable
              : subjectCode as String,
      subjectPlace:
          subjectPlace == const $CopyWithPlaceholder() || subjectPlace == null
              ? _value.subjectPlace
              // ignore: cast_nullable_to_non_nullable
              : subjectPlace as String,
      subjectTime:
          subjectTime == const $CopyWithPlaceholder() || subjectTime == null
              ? _value.subjectTime
              // ignore: cast_nullable_to_non_nullable
              : subjectTime as String,
      floor: floor == const $CopyWithPlaceholder() || floor == null
          ? _value.floor
          // ignore: cast_nullable_to_non_nullable
          : floor as String,
      seatNo: seatNo == const $CopyWithPlaceholder() || seatNo == null
          ? _value.seatNo
          // ignore: cast_nullable_to_non_nullable
          : seatNo as String,
    );
  }
}

extension $ChapelCopyWith on Chapel {
  /// Returns a callable class that can be used as follows: `instanceOfChapel.copyWith(...)` or like so:`instanceOfChapel.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ChapelCWProxy get copyWith => _$ChapelCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chapel _$ChapelFromJson(Map<String, dynamic> json) => Chapel(
      YearSemester.fromJson(json['currentSemester'] as Map<String, dynamic>),
      const _DataConverter().fromJson(json['attendances'] as List),
      subjectCode: json['subjectCode'] as String? ?? "",
      subjectPlace: json['subjectPlace'] as String? ?? "",
      subjectTime: json['subjectTime'] as String? ?? "",
      floor: json['floor'] as String? ?? "",
      seatNo: json['seatNo'] as String? ?? "",
    );

Map<String, dynamic> _$ChapelToJson(Chapel instance) => <String, dynamic>{
      'currentSemester': instance.currentSemester,
      'attendances': const _DataConverter().toJson(instance.attendances),
      'subjectCode': instance.subjectCode,
      'subjectPlace': instance.subjectPlace,
      'subjectTime': instance.subjectTime,
      'floor': instance.floor,
      'seatNo': instance.seatNo,
    };
