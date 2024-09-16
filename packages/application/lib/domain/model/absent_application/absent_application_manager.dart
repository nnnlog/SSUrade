import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade_application/domain/model/absent_application/absent_application.dart';

part 'absent_application_manager.g.dart';

@JsonSerializable()
class AbsentApplicationManager {
  @JsonKey()
  final List<AbsentApplication> data;

  const AbsentApplicationManager(this.data);

  factory AbsentApplicationManager.empty() => AbsentApplicationManager([]);

  bool get isEmpty => data.isEmpty;

  bool get isNotEmpty => data.isNotEmpty;

  // JSON Serialization
  factory AbsentApplicationManager.fromJson(Map<String, dynamic> json) => _$AbsentApplicationManagerFromJson(json);

  Map<String, dynamic> toJson() => _$AbsentApplicationManagerToJson(this);
}
