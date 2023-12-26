import 'package:json_annotation/json_annotation.dart';

part 'Ranking.g.dart';

@JsonSerializable()
class Ranking {
  static final Ranking unknown = Ranking(0, 0);

  @JsonKey()
  int my;
  @JsonKey()
  int total;

  Ranking(this.my, this.total);

  factory Ranking.fromJson(Map<String, dynamic> json) => _$RankingFromJson(json);

  Map<String, dynamic> toJson() => _$RankingToJson(this);

  factory Ranking.parse(String str) {
    try {
      var a = str.split("/").map((e) => int.parse(e)).toList();
      return Ranking(a[0], a[1]);
    } catch (e) {
      return Ranking.unknown;
    }
  }

  double get percentage {
    return my / total * 100;
  }

  bool get isEmpty => my == 0 || total == 0;

  bool get isNotEmpty => !isEmpty;

  String get display => isEmpty ? "-" : "$my/$total";

  @override
  String toString() => "$runtimeType(my=$my, total=$total)";
}
