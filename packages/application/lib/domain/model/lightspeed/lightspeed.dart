import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lightspeed.g.dart';

@CopyWith()
@JsonSerializable()
class Lightspeed extends Equatable {
  @JsonKey()
  final String version;
  @JsonKey()
  final String data;

  const Lightspeed({
    required this.version,
    required this.data,
  });

  @override
  List<Object?> get props => [version, data];

  factory Lightspeed.fromJson(Map<String, dynamic> json) => _$LightspeedFromJson(json);

  Map<String, dynamic> toJson() => _$LightspeedToJson(this);

  bool get isEmpty => data.isEmpty;

  bool get isNotEmpty => data.isNotEmpty;
}
