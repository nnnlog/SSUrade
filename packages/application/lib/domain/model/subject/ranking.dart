import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ranking.g.dart';

@CopyWith()
@JsonSerializable()
class Ranking extends Equatable {
  static const Ranking unknown = Ranking(my: 0, total: 0);

  @JsonKey()
  final int my;
  @JsonKey()
  final int total;

  const Ranking({
    required this.my,
    required this.total,
  });

  @override
  List<Object?> get props => [my, total];

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
