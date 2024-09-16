// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SubjectCWProxy {
  Subject code(String code);

  Subject name(String name);

  Subject credit(double credit);

  Subject grade(String grade);

  Subject score(String score);

  Subject professor(String professor);

  Subject category(String category);

  Subject isPassFail(bool isPassFail);

  Subject info(String info);

  Subject detail(Map<String, String> detail);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Subject(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Subject(...).copyWith(id: 12, name: "My name")
  /// ````
  Subject call({
    String? code,
    String? name,
    double? credit,
    String? grade,
    String? score,
    String? professor,
    String? category,
    bool? isPassFail,
    String? info,
    Map<String, String>? detail,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSubject.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSubject.copyWith.fieldName(...)`
class _$SubjectCWProxyImpl implements _$SubjectCWProxy {
  const _$SubjectCWProxyImpl(this._value);

  final Subject _value;

  @override
  Subject code(String code) => this(code: code);

  @override
  Subject name(String name) => this(name: name);

  @override
  Subject credit(double credit) => this(credit: credit);

  @override
  Subject grade(String grade) => this(grade: grade);

  @override
  Subject score(String score) => this(score: score);

  @override
  Subject professor(String professor) => this(professor: professor);

  @override
  Subject category(String category) => this(category: category);

  @override
  Subject isPassFail(bool isPassFail) => this(isPassFail: isPassFail);

  @override
  Subject info(String info) => this(info: info);

  @override
  Subject detail(Map<String, String> detail) => this(detail: detail);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Subject(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Subject(...).copyWith(id: 12, name: "My name")
  /// ````
  Subject call({
    Object? code = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? credit = const $CopyWithPlaceholder(),
    Object? grade = const $CopyWithPlaceholder(),
    Object? score = const $CopyWithPlaceholder(),
    Object? professor = const $CopyWithPlaceholder(),
    Object? category = const $CopyWithPlaceholder(),
    Object? isPassFail = const $CopyWithPlaceholder(),
    Object? info = const $CopyWithPlaceholder(),
    Object? detail = const $CopyWithPlaceholder(),
  }) {
    return Subject(
      code: code == const $CopyWithPlaceholder() || code == null
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      credit: credit == const $CopyWithPlaceholder() || credit == null
          ? _value.credit
          // ignore: cast_nullable_to_non_nullable
          : credit as double,
      grade: grade == const $CopyWithPlaceholder() || grade == null
          ? _value.grade
          // ignore: cast_nullable_to_non_nullable
          : grade as String,
      score: score == const $CopyWithPlaceholder() || score == null
          ? _value.score
          // ignore: cast_nullable_to_non_nullable
          : score as String,
      professor: professor == const $CopyWithPlaceholder() || professor == null
          ? _value.professor
          // ignore: cast_nullable_to_non_nullable
          : professor as String,
      category: category == const $CopyWithPlaceholder() || category == null
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as String,
      isPassFail:
          isPassFail == const $CopyWithPlaceholder() || isPassFail == null
              ? _value.isPassFail
              // ignore: cast_nullable_to_non_nullable
              : isPassFail as bool,
      info: info == const $CopyWithPlaceholder() || info == null
          ? _value.info
          // ignore: cast_nullable_to_non_nullable
          : info as String,
      detail: detail == const $CopyWithPlaceholder() || detail == null
          ? _value.detail
          // ignore: cast_nullable_to_non_nullable
          : detail as Map<String, String>,
    );
  }
}

extension $SubjectCopyWith on Subject {
  /// Returns a callable class that can be used as follows: `instanceOfSubject.copyWith(...)` or like so:`instanceOfSubject.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SubjectCWProxy get copyWith => _$SubjectCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subject _$SubjectFromJson(Map<String, dynamic> json) => Subject(
      code: json['code'] as String,
      name: json['name'] as String,
      credit: (json['credit'] as num).toDouble(),
      grade: json['grade'] as String,
      score: json['score'] as String,
      professor: json['professor'] as String,
      category: json['category'] as String,
      isPassFail: json['isPassFail'] as bool,
      info: json['info'] as String,
      detail: Map<String, String>.from(json['detail'] as Map),
    );

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'credit': instance.credit,
      'grade': instance.grade,
      'score': instance.score,
      'professor': instance.professor,
      'category': instance.category,
      'isPassFail': instance.isPassFail,
      'info': instance.info,
      'detail': instance.detail,
    };
