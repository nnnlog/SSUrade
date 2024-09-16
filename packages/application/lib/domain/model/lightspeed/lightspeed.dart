import 'package:json_annotation/json_annotation.dart';

part 'lightspeed.g.dart';

@JsonSerializable()
class Lightspeed {
  @JsonKey()
  final String version;
  @JsonKey()
  final String data;

  const Lightspeed({
    required this.version,
    required this.data,
  });

  factory Lightspeed.fromJson(Map<String, dynamic> json) => _$LightspeedFromJson(json);

  Map<String, dynamic> toJson() => _$LightspeedToJson(this);

  bool get isEmpty => data.isEmpty;

  bool get isNotEmpty => data.isNotEmpty;
}
