// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scholarship.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ScholarshipCWProxy {
  Scholarship when(YearSemester when);

  Scholarship name(String name);

  Scholarship process(String process);

  Scholarship price(String price);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Scholarship(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Scholarship(...).copyWith(id: 12, name: "My name")
  /// ````
  Scholarship call({
    YearSemester? when,
    String? name,
    String? process,
    String? price,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfScholarship.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfScholarship.copyWith.fieldName(...)`
class _$ScholarshipCWProxyImpl implements _$ScholarshipCWProxy {
  const _$ScholarshipCWProxyImpl(this._value);

  final Scholarship _value;

  @override
  Scholarship when(YearSemester when) => this(when: when);

  @override
  Scholarship name(String name) => this(name: name);

  @override
  Scholarship process(String process) => this(process: process);

  @override
  Scholarship price(String price) => this(price: price);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Scholarship(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Scholarship(...).copyWith(id: 12, name: "My name")
  /// ````
  Scholarship call({
    Object? when = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? process = const $CopyWithPlaceholder(),
    Object? price = const $CopyWithPlaceholder(),
  }) {
    return Scholarship(
      when: when == const $CopyWithPlaceholder() || when == null
          ? _value.when
          // ignore: cast_nullable_to_non_nullable
          : when as YearSemester,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      process: process == const $CopyWithPlaceholder() || process == null
          ? _value.process
          // ignore: cast_nullable_to_non_nullable
          : process as String,
      price: price == const $CopyWithPlaceholder() || price == null
          ? _value.price
          // ignore: cast_nullable_to_non_nullable
          : price as String,
    );
  }
}

extension $ScholarshipCopyWith on Scholarship {
  /// Returns a callable class that can be used as follows: `instanceOfScholarship.copyWith(...)` or like so:`instanceOfScholarship.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ScholarshipCWProxy get copyWith => _$ScholarshipCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Scholarship _$ScholarshipFromJson(Map<String, dynamic> json) => Scholarship(
      when: YearSemester.fromJson(json['when'] as Map<String, dynamic>),
      name: json['name'] as String,
      process: json['process'] as String,
      price: json['price'] as String,
    );

Map<String, dynamic> _$ScholarshipToJson(Scholarship instance) => <String, dynamic>{
      'when': instance.when,
      'name': instance.name,
      'process': instance.process,
      'price': instance.price,
    };
