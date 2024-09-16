import 'package:json_annotation/json_annotation.dart';

part 'ranking.g.dart';

@JsonSerializable()
class Ranking {
  static const Ranking unknown = Ranking(my: 0, total: 0);

  @JsonKey()
  final int my;
  @JsonKey()
  final int total;

  const Ranking({
    required this.my,
    required this.total,
  });

  factory Ranking.fromJson(Map<String, dynamic> json) => _$RankingFromJson(json);

  Map<String, dynamic> toJson() => _$RankingToJson(this);

  factory Ranking.parse(String str) {
    try {
      var a = str.split("/").map((e) => int.parse(e)).toList();
      return Ranking(my: a[0], total: a[1]);
    } catch (e) {
      return Ranking.unknown;
    }
  }

  double get percentage {
    return (my * 1000 ~/ total) / 10;
  }

  bool get isEmpty => my == 0 || total == 0;

  bool get isNotEmpty => !isEmpty;

  String get display => isEmpty ? "-" : "$my/$total";
}
