// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ranking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ranking _$RankingFromJson(Map<String, dynamic> json) => Ranking(
      (json['my'] as num).toInt(),
      (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$RankingToJson(Ranking instance) => <String, dynamic>{
      'my': instance.my,
      'total': instance.total,
    };
