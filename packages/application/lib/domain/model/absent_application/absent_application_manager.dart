import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ssurade_application/domain/model/absent_application/absent_application.dart';

part 'absent_application_manager.g.dart';

@CopyWith()
@JsonSerializable()
class AbsentApplicationManager extends Equatable {
  @JsonKey()
  final List<AbsentApplication> data;

  const AbsentApplicationManager(this.data);

  factory AbsentApplicationManager.empty() => AbsentApplicationManager([]);

  @override
  List<Object?> get props => [data];

  bool get isEmpty => data.isEmpty;

  bool get isNotEmpty => data.isNotEmpty;

  // JSON Serialization
  factory AbsentApplicationManager.fromJson(Map<String, dynamic> json) => _$AbsentApplicationManagerFromJson(json);

  Map<String, dynamic> toJson() => _$AbsentApplicationManagerToJson(this);
}
