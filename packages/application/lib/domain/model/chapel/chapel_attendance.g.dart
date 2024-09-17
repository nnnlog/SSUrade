// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapel_attendance.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChapelAttendanceCWProxy {
  ChapelAttendance attendance(ChapelAttendanceStatus attendance);

  ChapelAttendance overwrittenAttendance(
      ChapelAttendanceStatus overwrittenAttendance);

  ChapelAttendance affiliation(String affiliation);

  ChapelAttendance lectureDate(String lectureDate);

  ChapelAttendance lectureEtc(String lectureEtc);

  ChapelAttendance lectureName(String lectureName);

  ChapelAttendance lectureType(String lectureType);

  ChapelAttendance lecturer(String lecturer);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChapelAttendance(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChapelAttendance(...).copyWith(id: 12, name: "My name")
  /// ````
  ChapelAttendance call({
    ChapelAttendanceStatus? attendance,
    ChapelAttendanceStatus? overwrittenAttendance,
    String? affiliation,
    String? lectureDate,
    String? lectureEtc,
    String? lectureName,
    String? lectureType,
    String? lecturer,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfChapelAttendance.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfChapelAttendance.copyWith.fieldName(...)`
class _$ChapelAttendanceCWProxyImpl implements _$ChapelAttendanceCWProxy {
  const _$ChapelAttendanceCWProxyImpl(this._value);

  final ChapelAttendance _value;

  @override
  ChapelAttendance attendance(ChapelAttendanceStatus attendance) =>
      this(attendance: attendance);

  @override
  ChapelAttendance overwrittenAttendance(
          ChapelAttendanceStatus overwrittenAttendance) =>
      this(overwrittenAttendance: overwrittenAttendance);

  @override
  ChapelAttendance affiliation(String affiliation) =>
      this(affiliation: affiliation);

  @override
  ChapelAttendance lectureDate(String lectureDate) =>
      this(lectureDate: lectureDate);

  @override
  ChapelAttendance lectureEtc(String lectureEtc) =>
      this(lectureEtc: lectureEtc);

  @override
  ChapelAttendance lectureName(String lectureName) =>
      this(lectureName: lectureName);

  @override
  ChapelAttendance lectureType(String lectureType) =>
      this(lectureType: lectureType);

  @override
  ChapelAttendance lecturer(String lecturer) => this(lecturer: lecturer);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChapelAttendance(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChapelAttendance(...).copyWith(id: 12, name: "My name")
  /// ````
  ChapelAttendance call({
    Object? attendance = const $CopyWithPlaceholder(),
    Object? overwrittenAttendance = const $CopyWithPlaceholder(),
    Object? affiliation = const $CopyWithPlaceholder(),
    Object? lectureDate = const $CopyWithPlaceholder(),
    Object? lectureEtc = const $CopyWithPlaceholder(),
    Object? lectureName = const $CopyWithPlaceholder(),
    Object? lectureType = const $CopyWithPlaceholder(),
    Object? lecturer = const $CopyWithPlaceholder(),
  }) {
    return ChapelAttendance(
      attendance:
          attendance == const $CopyWithPlaceholder() || attendance == null
              ? _value.attendance
              // ignore: cast_nullable_to_non_nullable
              : attendance as ChapelAttendanceStatus,
      overwrittenAttendance:
          overwrittenAttendance == const $CopyWithPlaceholder() ||
                  overwrittenAttendance == null
              ? _value.overwrittenAttendance
              // ignore: cast_nullable_to_non_nullable
              : overwrittenAttendance as ChapelAttendanceStatus,
      affiliation:
          affiliation == const $CopyWithPlaceholder() || affiliation == null
              ? _value.affiliation
              // ignore: cast_nullable_to_non_nullable
              : affiliation as String,
      lectureDate:
          lectureDate == const $CopyWithPlaceholder() || lectureDate == null
              ? _value.lectureDate
              // ignore: cast_nullable_to_non_nullable
              : lectureDate as String,
      lectureEtc:
          lectureEtc == const $CopyWithPlaceholder() || lectureEtc == null
              ? _value.lectureEtc
              // ignore: cast_nullable_to_non_nullable
              : lectureEtc as String,
      lectureName:
          lectureName == const $CopyWithPlaceholder() || lectureName == null
              ? _value.lectureName
              // ignore: cast_nullable_to_non_nullable
              : lectureName as String,
      lectureType:
          lectureType == const $CopyWithPlaceholder() || lectureType == null
              ? _value.lectureType
              // ignore: cast_nullable_to_non_nullable
              : lectureType as String,
      lecturer: lecturer == const $CopyWithPlaceholder() || lecturer == null
          ? _value.lecturer
          // ignore: cast_nullable_to_non_nullable
          : lecturer as String,
    );
  }
}

extension $ChapelAttendanceCopyWith on ChapelAttendance {
  /// Returns a callable class that can be used as follows: `instanceOfChapelAttendance.copyWith(...)` or like so:`instanceOfChapelAttendance.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ChapelAttendanceCWProxy get copyWith => _$ChapelAttendanceCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChapelAttendance _$ChapelAttendanceFromJson(Map<String, dynamic> json) =>
    ChapelAttendance(
      attendance:
          $enumDecode(_$ChapelAttendanceStatusEnumMap, json['attendance']),
      overwrittenAttendance: $enumDecode(
          _$ChapelAttendanceStatusEnumMap, json['overwrittenAttendance']),
      affiliation: json['affiliation'] as String,
      lectureDate: json['lectureDate'] as String,
      lectureEtc: json['lectureEtc'] as String,
      lectureName: json['lectureName'] as String,
      lectureType: json['lectureType'] as String,
      lecturer: json['lecturer'] as String,
    );

Map<String, dynamic> _$ChapelAttendanceToJson(ChapelAttendance instance) =>
    <String, dynamic>{
      'attendance': _$ChapelAttendanceStatusEnumMap[instance.attendance]!,
      'overwrittenAttendance':
          _$ChapelAttendanceStatusEnumMap[instance.overwrittenAttendance]!,
      'affiliation': instance.affiliation,
      'lectureDate': instance.lectureDate,
      'lectureEtc': instance.lectureEtc,
      'lectureName': instance.lectureName,
      'lectureType': instance.lectureType,
      'lecturer': instance.lecturer,
    };

const _$ChapelAttendanceStatusEnumMap = {
  ChapelAttendanceStatus.unknown: 'unknown',
  ChapelAttendanceStatus.absent: 'absent',
  ChapelAttendanceStatus.attend: 'attend',
};
