// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'absent_application.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AbsentApplicationCWProxy {
  AbsentApplication absentType(String absentType);

  AbsentApplication startDate(String startDate);

  AbsentApplication endDate(String endDate);

  AbsentApplication absentCause(String absentCause);

  AbsentApplication applicationDate(String applicationDate);

  AbsentApplication proceedDate(String proceedDate);

  AbsentApplication rejectCause(String rejectCause);

  AbsentApplication status(String status);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AbsentApplication(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AbsentApplication(...).copyWith(id: 12, name: "My name")
  /// ````
  AbsentApplication call({
    String? absentType,
    String? startDate,
    String? endDate,
    String? absentCause,
    String? applicationDate,
    String? proceedDate,
    String? rejectCause,
    String? status,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAbsentApplication.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAbsentApplication.copyWith.fieldName(...)`
class _$AbsentApplicationCWProxyImpl implements _$AbsentApplicationCWProxy {
  const _$AbsentApplicationCWProxyImpl(this._value);

  final AbsentApplication _value;

  @override
  AbsentApplication absentType(String absentType) => this(absentType: absentType);

  @override
  AbsentApplication startDate(String startDate) => this(startDate: startDate);

  @override
  AbsentApplication endDate(String endDate) => this(endDate: endDate);

  @override
  AbsentApplication absentCause(String absentCause) => this(absentCause: absentCause);

  @override
  AbsentApplication applicationDate(String applicationDate) => this(applicationDate: applicationDate);

  @override
  AbsentApplication proceedDate(String proceedDate) => this(proceedDate: proceedDate);

  @override
  AbsentApplication rejectCause(String rejectCause) => this(rejectCause: rejectCause);

  @override
  AbsentApplication status(String status) => this(status: status);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AbsentApplication(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AbsentApplication(...).copyWith(id: 12, name: "My name")
  /// ````
  AbsentApplication call({
    Object? absentType = const $CopyWithPlaceholder(),
    Object? startDate = const $CopyWithPlaceholder(),
    Object? endDate = const $CopyWithPlaceholder(),
    Object? absentCause = const $CopyWithPlaceholder(),
    Object? applicationDate = const $CopyWithPlaceholder(),
    Object? proceedDate = const $CopyWithPlaceholder(),
    Object? rejectCause = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
  }) {
    return AbsentApplication(
      absentType: absentType == const $CopyWithPlaceholder() || absentType == null
          ? _value.absentType
          // ignore: cast_nullable_to_non_nullable
          : absentType as String,
      startDate: startDate == const $CopyWithPlaceholder() || startDate == null
          ? _value.startDate
          // ignore: cast_nullable_to_non_nullable
          : startDate as String,
      endDate: endDate == const $CopyWithPlaceholder() || endDate == null
          ? _value.endDate
          // ignore: cast_nullable_to_non_nullable
          : endDate as String,
      absentCause: absentCause == const $CopyWithPlaceholder() || absentCause == null
          ? _value.absentCause
          // ignore: cast_nullable_to_non_nullable
          : absentCause as String,
      applicationDate: applicationDate == const $CopyWithPlaceholder() || applicationDate == null
          ? _value.applicationDate
          // ignore: cast_nullable_to_non_nullable
          : applicationDate as String,
      proceedDate: proceedDate == const $CopyWithPlaceholder() || proceedDate == null
          ? _value.proceedDate
          // ignore: cast_nullable_to_non_nullable
          : proceedDate as String,
      rejectCause: rejectCause == const $CopyWithPlaceholder() || rejectCause == null
          ? _value.rejectCause
          // ignore: cast_nullable_to_non_nullable
          : rejectCause as String,
      status: status == const $CopyWithPlaceholder() || status == null
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String,
    );
  }
}

extension $AbsentApplicationCopyWith on AbsentApplication {
  /// Returns a callable class that can be used as follows: `instanceOfAbsentApplication.copyWith(...)` or like so:`instanceOfAbsentApplication.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AbsentApplicationCWProxy get copyWith => _$AbsentApplicationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AbsentApplication _$AbsentApplicationFromJson(Map<String, dynamic> json) => AbsentApplication(
      absentType: json['absentType'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      absentCause: json['absentCause'] as String,
      applicationDate: json['applicationDate'] as String,
      proceedDate: json['proceedDate'] as String,
      rejectCause: json['rejectCause'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$AbsentApplicationToJson(AbsentApplication instance) => <String, dynamic>{
      'absentType': instance.absentType,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'absentCause': instance.absentCause,
      'applicationDate': instance.applicationDate,
      'proceedDate': instance.proceedDate,
      'rejectCause': instance.rejectCause,
      'status': instance.status,
    };
