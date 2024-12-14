// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ranking.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RankingCWProxy {
  Ranking my(int my);

  Ranking total(int total);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Ranking(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Ranking(...).copyWith(id: 12, name: "My name")
  /// ````
  Ranking call({
    int my,
    int total,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRanking.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRanking.copyWith.fieldName(...)`
class _$RankingCWProxyImpl implements _$RankingCWProxy {
  const _$RankingCWProxyImpl(this._value);

  final Ranking _value;

  @override
  Ranking my(int my) => this(my: my);

  @override
  Ranking total(int total) => this(total: total);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Ranking(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Ranking(...).copyWith(id: 12, name: "My name")
  /// ````
  Ranking call({
    Object? my = const $CopyWithPlaceholder(),
    Object? total = const $CopyWithPlaceholder(),
  }) {
    return Ranking(
      my: my == const $CopyWithPlaceholder()
          ? _value.my
          // ignore: cast_nullable_to_non_nullable
          : my as int,
      total: total == const $CopyWithPlaceholder()
          ? _value.total
          // ignore: cast_nullable_to_non_nullable
          : total as int,
    );
  }
}

extension $RankingCopyWith on Ranking {
  /// Returns a callable class that can be used as follows: `instanceOfRanking.copyWith(...)` or like so:`instanceOfRanking.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RankingCWProxy get copyWith => _$RankingCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ranking _$RankingFromJson(Map<String, dynamic> json) => Ranking(
      my: (json['my'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$RankingToJson(Ranking instance) => <String, dynamic>{
      'my': instance.my,
      'total': instance.total,
    };
